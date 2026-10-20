# Lab 10: the shop's price list is read by a page on another origin (the
# personal page on GitHub Pages). The browser shows that page the answer
# only if the API names its origin here. Exactly two origins, never "*":
# the published page, and the local server used while developing it (on
# port 8000, not the API's 3000).
#
# Only the routes the page reads are opened, and only with GET (and the
# OPTIONS of a preflight). The routes that need the token — the repairs and
# POST /api/v1/services — are not opened to any origin.
#
# CORS is a rule for browsers: a request without an Origin header (curl, the
# accounting program, the owner's script) is answered exactly as before.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://rodrigoruzv.github.io", "http://localhost:8000"

    resource "/api/v1/services", headers: :any, methods: [ :get, :options ]
    resource "/api/v1/services/*", headers: :any, methods: [ :get, :options ]
  end
end
