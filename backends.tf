terraform {
  cloud {
    organization = "oe-terransible"

    workspaces {
      name = "terransible"
    }
  }
}