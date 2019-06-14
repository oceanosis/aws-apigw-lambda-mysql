resource "aws_lambda_function" "put_hw" {
  function_name = "put_helloworld"
  filename      = "../lambda_py/put_helloworld.zip"
  handler = "lambda_put_handler.handler"
  runtime = "python3.6"
  #source_code_hash = "${base64sha256(file("../lambda_py/put_helloworld.zip"))}"
  role = "${aws_iam_role.lambda_exec.arn}"
  vpc_config {
    subnet_ids = "${module.hwvpc.private_subnet_ids}"
    security_group_ids = ["${aws_security_group.private-sg.id}"]
  }
}

resource "aws_lambda_function" "get_hw" {
  function_name = "get_helloworld"
  filename      = "../lambda_py/get_helloworld.zip"
  handler = "lambda_get_handler.handler"
  runtime = "python3.6"
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
      "Action": [
          "sts:AssumeRole"
    ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_attach_lambdavpc" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
