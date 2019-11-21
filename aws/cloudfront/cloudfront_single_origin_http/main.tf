locals {
  http_origin_id = "web_app"
}

module "aws_cf_dist_http" {
    source = "../cloudfront_multiple_origins"
    origins = [{
        is_s3_origin = false
        domain_name = var.domain_name
        origin_id = "${local.http_origin_id}"
    }]
    default_cache_behavior = {
        allowed_methods = "${var.cache_behavior_allowed_methods}"
        cached_methods = "${var.cache_behavior_cached_methods}"
        origin_id = "${local.http_origin_id}"
        forwarded_values_query_string = true
        forwarded_values_cookies_forward = "all"
        lambda_function_association_lambda_arn = "${var.request_lambda_edge_function_arn}"
        lambda_function_association_include_body = "${var.request_lambda_edge_function_include_body}"
        min_ttl = "${var.cache_behavior_min_ttl}"
        default_ttl = "${var.cache_behavior_default_ttl}"
        max_ttl = "${var.cache_behavior_max_ttl}"
    }

    custom_error_responses = [{
        error_caching_min_ttl = "${var.custom_error_response_error_caching_min_ttl}"
        error_code            = "403"
        response_code         = "${var.custom_error_response_code}"
        response_page_path    = "${var.custom_error_response_page_path}"
    }]

    custom_error_responses = "${var.custom_error_responses}"

    comment = "${var.comment}"
    logging_enable = "${var.logging_enable}"
    logging_include_cookies = "${var.logging_include_cookies}"
    logging_bucket = "${var.logging_bucket}"
    logging_prefix = "${var.logging_prefix}"
    wait_for_deployment = "${var.wait_for_deployment}"
}
