data "template_file" "cloud_init" {
    template = file(var.cloud_init_path)
}