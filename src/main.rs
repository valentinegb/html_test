use axum::{Router, response::Html, routing::get};

#[tokio::main]
async fn main() {
    let router = Router::new().route(
        "/",
        get(async || Html("If you're seeing this, you have successfully connected.")),
    );
    let listener = tokio::net::TcpListener::bind("0.0.0.0:80").await.unwrap();

    axum::serve(listener, router).await.unwrap();
}
