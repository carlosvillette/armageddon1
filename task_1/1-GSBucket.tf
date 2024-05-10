resource "google_storage_bucket" "static-site" {
  name          = "guy-carlos-villette-static-site"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
  }
  
}


resource "google_storage_default_object_access_control" "website_read" {
  bucket = google_storage_bucket.static-site.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  source = "./content/index.html"
  bucket = google_storage_bucket.static-site.name
}

resource "google_storage_bucket_object" "picture" {
  name   = "hot-brazilian-women.jpg"
  source = "./images/hot-brazilian-women.jpg"
  bucket = google_storage_bucket.static-site.name
}