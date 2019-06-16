resource "aws_lambda_function" "put_hw" {
  function_name = "put_helloworld"
  filename      = "../lambda_py/put_helloworld.zip"
  handler = "lambda_put.handler"
  runtime = "python3.6"
  timeout = 100
  #source_code_hash = "${base64sha256(file("../lambda_py/put_helloworld.zip"))}"
  role = "${aws_iam_role.lambda_exec.arn}"
  vpc_config {
    subnet_ids = "${module.hwvpc.public_subnet_ids}"
    security_group_ids = ["${aws_security_group.public-sg.id}"]
  }
}

resource "aws_lambda_function" "get_hw" {
  function_name = "get_helloworld"
  filename      = "../lambda_py/get_helloworld.zip"
  handler = "lambda_get.handler"
  runtime = "python3.6"
  timeout = 100
  #source_code_hash = "${base64sha256(file("../lambda_py/put_helloworld.zip"))}"
  role = "${aws_iam_role.lambda_exec.arn}"
  vpc_config {
    subnet_ids = "${module.hwvpc.private_subnet_ids}"
    security_group_ids = ["${aws_security_group.private-sg.id}"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "helloworld_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_attach_lambda_vpc" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_api_gateway_rest_api" "helloworld_api" {
  name        = "helloworld"
  description = "Helloworld api for putting and getting dateOfBirth of users"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "*",
      "Condition": {
          "IpAddress": {
              "aws:SourceIp": "${var.trusted_ip_range}"
          }
      }
    }
  ]
}
EOF
}

resource "aws_api_gateway_resource" "hello_part" {
  rest_api_id = "${aws_api_gateway_rest_api.helloworld_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.helloworld_api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_resource" "proxy_hello_part" {
  rest_api_id = "${aws_api_gateway_rest_api.helloworld_api.id}"
  parent_id   = "${aws_api_gateway_resource.hello_part.id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "put_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.helloworld_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_hello_part.id}"
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "get_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.helloworld_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_hello_part.id}"
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method_response" "put_response_204" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method   = aws_api_gateway_method.put_proxy.http_method
  status_code = 204

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "get_response_200" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method   = aws_api_gateway_method.get_proxy.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "lambda_put" {
  rest_api_id = "${aws_api_gateway_rest_api.helloworld_api.id}"
  resource_id = "${aws_api_gateway_method.put_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.put_proxy.http_method}"
  timeout_milliseconds = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.put_hw.invoke_arn}"
  request_templates = {
    "application/json" = "{ 'username':'testuser', 'dateOfBirth':'2018-01-01'}"
  }
}

resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id = "${aws_api_gateway_rest_api.helloworld_api.id}"
  resource_id = "${aws_api_gateway_method.get_proxy.resource_id}"
  http_method = "${aws_api_gateway_method.get_proxy.http_method}"
  timeout_milliseconds = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.get_hw.invoke_arn}"
  request_templates = {
    "application/json" = "{ 'username':'testuser'}"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_put",
    "aws_api_gateway_integration.lambda_get",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.helloworld_api.id}"
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw_put_perms" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.put_hw.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.helloworld_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apigw_get_perms" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_hw.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.helloworld_api.execution_arn}/*/*/*"
}

# MOCK TEST

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_204" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = 204

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 204,
  "body" : $input.json('$')
}
EOF

  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.proxy_hello_part.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_204.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
