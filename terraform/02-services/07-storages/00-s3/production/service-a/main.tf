module "simple_bucket" {
  source = "../../"

  bucket = "simple-${random_pet.this.id}"

  force_destroy = true
}
