# Create IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2_SSM_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# Attach AmazonSSMManagedInstanceCore policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}
# Create an instance profile for the EC2 instance and associate the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_SSM_Instance_Profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_s3_bucket_object" "script" {
  bucket = "lexi-bucket"
  key    = "script.sh"
  source = "/home/ubuntu/ec2/script.sh"
  etag   = filemd5("/home/ubuntu/ec2/script.sh")
}



resource "aws_imagebuilder_component" "example" {
  name        = "example"
  description = "Example component"
  version     = "1.0.0"
  platform = "Linux"
  data = <<-EOT
    schemaVersion: '1.0'
    description: 'Example component'
    phases:
      - name: build
        steps:
          - name: ExecuteScript
            action: ExecuteBash
            inputs:
              commands:
                - |
                  sudo apt update
                  sudo apt install -y nginx php-fpm php-mysql mysql-server
                  sudo systemctl enable php7.4-fpm
                  sudo apt install unzip -y
                  wget https://github.com/bcit-ci/CodeIgniter/archive/3.1.11.zip
                  unzip 3.1.11.zip
                  sudo mv CodeIgniter-3.1.11 /var/www/html/codeigniter
                  sudo chown -R www-data:www-data /var/www/html/codeigniter
                  sudo chmod -R 755 /var/www/html/codeigniter/application/cache
                  sudo chmod -R 755 /var/www/html/codeigniter/application/logs
                  sudo cp /var/www/html/codeigniter/application/config/database.php /var/www/html/codeigniter/application/config/database.php.bak
                  sudo sh -c 'cat > /var/www/html/codeigniter/application/config/database.php <<EOF
                  <?php
                  defined("BASEPATH") or exit("No direct script access allowed");

                  \$active_group = "default";
                  \$query_builder = TRUE;

                  \$db["default"] = array(
                      "dsn"   => "",
                      "hostname" => "localhost",
                      "username" => "admin",
                      "password" => "123456",
                      "database" => "dbadmin",
                      "dbdriver" => "mysqli",
                      "dbprefix" => "",
                      "pconnect" => FALSE,
                      "db_debug" => (ENVIRONMENT !== "production"),
                      "cache_on" => FALSE,
                      "cachedir" => "",
                      "char_set" => "utf8",
                      "dbcollat" => "utf8_general_ci",
                      "swap_pre" => "",
                      "encrypt" => FALSE,
                      "compress" => FALSE,
                      "stricton" => FALSE,
                      "failover" => array(),
                      "save_queries" => TRUE
                  );

                  EOF'
                  sudo rm /etc/nginx/sites-available/default
                  sudo sh -c 'echo "
                  server {
                      listen 80;
                      listen [::]:80;
                      root /var/www/html/codeigniter;
                      index index.php index.html index.htm;

                      location / {
                          try_files \$uri \$uri/ /index.php?\$args;
                      }

                      location ~ \.php$ {
                          include snippets/fastcgi-php.conf;
                          fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                      }
                  }
                  " > /etc/nginx/sites-available/default'
                  sudo systemctl restart nginx
                  sudo systemctl restart php7.4-fpm
                  sudo systemctl restart mysql
                  echo "La instalación de CodeIgniter con Nginx en Ubuntu se ha completado. Asegúrate de configurar el servidor web correctamente."
    EOT
}


# Declare infrastructure configuration
resource "aws_imagebuilder_infrastructure_configuration" "this" {
  instance_profile_name         = aws_iam_instance_profile.ec2_instance_profile.name
  instance_types                = ["t2.nano"]
  key_pair                      = var.aws_key_pair_name
  name                          = "example-lexi"
  security_group_ids            = [data.aws_security_group.this.id]
  subnet_id                     = data.aws_subnet.this.id
  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = var.aws_s3_log_bucket
      s3_key_prefix  = "logs"
    }
  }

  tags = {
    foo = "bar"
  }
}

resource "aws_imagebuilder_image" "this" {
  #distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.example.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn

  depends_on = [
    data.aws_iam_policy_document.image_builder
  ]
}

resource "aws_imagebuilder_image_recipe" "this" {
  block_device_mapping {
    device_name = "/dev/xvdb"

    ebs {
      delete_on_termination = true
      volume_size           = var.ebs_root_vol_size
      volume_type           = "gp3"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.example.arn
  }

  name         = "ubuntu-recipe"
  parent_image = "ami-0c65adc9a5c1b5d7c"
  version = "1.0.0"
}



resource "aws_imagebuilder_image_pipeline" "this" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  name                             = "ubuntu_image_pipeline"
  status                           = "ENABLED"
  description                      = "Creates a Ununtu image."
  
  #Test the image after build
  image_tests_configuration {
    image_tests_enabled = true
    timeout_minutes     = 60
  }

  tags = {
    "Name" = "${var.ami_name_tag}-pipeline"
  }
}   
