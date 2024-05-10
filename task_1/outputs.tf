output "bucket_url" {
  description = "public link for bucket"
  value = "https://storage.googleapis.com/${google_storage_bucket.static-site.name}/index.html"
}