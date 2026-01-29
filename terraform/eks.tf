module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "ben-devops-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # --- תוספת 1: התקנת הדרייבר לדיסקים ---
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 3
      max_size     = 5
      desired_size = 3

      instance_types = ["t3.small"]
      
      # --- תוספת 2: מתן הרשאות לשרתים ליצור דיסקים ---
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }
  
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Project     = "devops-task"
  }
}