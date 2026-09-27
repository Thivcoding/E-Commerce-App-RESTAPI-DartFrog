import 'package:ecommerce_api/config/env.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  late final SmtpServer _smtpServer;

  EmailService() {
    _smtpServer = SmtpServer(
      Env.smtpHost,
      port: Env.smtpPort,
      username: Env.smtpUsername,
      password: Env.smtpPassword,
      ssl: Env.smtpPort == 465,
    );
  }

  Future<void> sendVerificationOtp({
    required String toEmail,
    required String name,
    required String otp,
  }) async {
    final message = Message()
      ..from = Address(
        Env.smtpFromEmail,
        Env.smtpFromName,
      )
      ..recipients.add(toEmail)
      ..subject = 'Your verification code - ${Env.smtpFromName}'
      ..html = _buildVerificationEmail(
        name: name,
        otp: otp,
      )
      ..text = _buildPlainTextEmail(
        name: name,
        otp: otp,
      );

    await send(
      message,
      _smtpServer,
    );
  }

  String _buildVerificationEmail({
    required String name,
    required String otp,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >

  <title>Verify Your Email</title>
</head>

<body
  style="
    margin:0;
    padding:0;
    background:#f4f7fb;
    font-family:Arial,Helvetica,sans-serif;
  "
>

  <table
    width="100%"
    cellpadding="0"
    cellspacing="0"
    border="0"
    style="background:#f4f7fb;padding:40px 15px;"
  >

    <tr>
      <td align="center">

        <!-- Main Card -->
        <table
          width="100%"
          cellpadding="0"
          cellspacing="0"
          border="0"
          style="
            max-width:560px;
            background:#ffffff;
            border-radius:16px;
            overflow:hidden;
            box-shadow:0 8px 30px rgba(0,0,0,0.08);
          "
        >

          <!-- Header -->
          <tr>
            <td
              align="center"
              style="
                background:#0d6efd;
                padding:32px 25px;
              "
            >

              <div
                style="
                  width:58px;
                  height:58px;
                  line-height:58px;
                  background:#ffffff;
                  border-radius:50%;
                  color:#0d6efd;
                  font-size:28px;
                  font-weight:bold;
                  margin:auto;
                "
              >
                🛍
              </div>

              <h1
                style="
                  margin:18px 0 5px;
                  color:#ffffff;
                  font-size:26px;
                  font-weight:700;
                "
              >
                ${Env.smtpFromName}
              </h1>

              <p
                style="
                  margin:0;
                  color:#dbeafe;
                  font-size:14px;
                "
              >
                Secure account verification
              </p>

            </td>
          </tr>


          <!-- Content -->
          <tr>
            <td style="padding:38px 35px 30px;">

              <h2
                style="
                  margin:0 0 12px;
                  color:#111827;
                  font-size:24px;
                "
              >
                Verify your email 🔐
              </h2>

              <p
                style="
                  margin:0 0 24px;
                  color:#4b5563;
                  font-size:15px;
                  line-height:1.7;
                "
              >
                Hello <strong>$name</strong>,
                <br><br>

                Thank you for creating an account with us.
                Please use the verification code below
                to confirm your email address.
              </p>


              <!-- OTP Box -->
              <table
                width="100%"
                cellpadding="0"
                cellspacing="0"
                border="0"
              >
                <tr>
                  <td
                    align="center"
                    style="
                      background:#f0f6ff;
                      border:1px solid #d7e7ff;
                      border-radius:14px;
                      padding:25px 15px;
                    "
                  >

                    <p
                      style="
                        margin:0 0 10px;
                        color:#6b7280;
                        font-size:12px;
                        text-transform:uppercase;
                        letter-spacing:2px;
                        font-weight:bold;
                      "
                    >
                      Verification Code
                    </p>

                    <div
                      style="
                        color:#0d6efd;
                        font-size:38px;
                        font-weight:800;
                        letter-spacing:10px;
                        padding-left:10px;
                      "
                    >
                      $otp
                    </div>

                  </td>
                </tr>
              </table>


              <!-- Expiration -->
              <table
                width="100%"
                cellpadding="0"
                cellspacing="0"
                border="0"
                style="margin-top:22px;"
              >
                <tr>
                  <td
                    style="
                      background:#fff8e6;
                      border:1px solid #ffe3a3;
                      border-radius:10px;
                      padding:14px 16px;
                    "
                  >

                    <p
                      style="
                        margin:0;
                        color:#8a5a00;
                        font-size:13px;
                        line-height:1.6;
                      "
                    >
                      ⏱️
                      <strong>This code expires in
                      ${Env.emailVerificationExpiresMinutes}
                      minutes.</strong>
                    </p>

                  </td>
                </tr>
              </table>


              <!-- Security -->
              <div style="margin-top:25px;">

                <p
                  style="
                    margin:0;
                    color:#6b7280;
                    font-size:13px;
                    line-height:1.7;
                  "
                >
                  🛡️ <strong>Security reminder</strong>
                  <br>

                  Never share this verification code with
                  anyone. Our team will never ask you for
                  your OTP or password.
                </p>

              </div>


              <p
                style="
                  margin:28px 0 0;
                  color:#6b7280;
                  font-size:13px;
                  line-height:1.6;
                "
              >
                If you didn't create this account, you can
                safely ignore this email.
              </p>

            </td>
          </tr>


          <!-- Footer -->
          <tr>
            <td
              align="center"
              style="
                background:#f9fafb;
                border-top:1px solid #eef0f3;
                padding:22px 25px;
              "
            >

              <p
                style="
                  margin:0;
                  color:#9ca3af;
                  font-size:12px;
                  line-height:1.6;
                "
              >
                © ${DateTime.now().year} ${Env.smtpFromName}
                <br>
                This is an automated message.
                Please do not reply.
              </p>

            </td>
          </tr>

        </table>

      </td>
    </tr>

  </table>

</body>
</html>
''';
  }

  String _buildPlainTextEmail({
    required String name,
    required String otp,
  }) {
    return '''
    Hello $name,

    Thank you for creating an account with ${Env.smtpFromName}.

    Your email verification code is:

    $otp

    This code will expire in
    ${Env.emailVerificationExpiresMinutes} minutes.

    For security, never share this code with anyone.

    If you did not create this account, you can safely ignore this email.

    © ${DateTime.now().year} ${Env.smtpFromName}
    ''';
  }

  Future<void> sendPasswordResetOtp({
    required String toEmail,
    required String name,
    required String otp,
  }) async {
    final message = Message()
      ..from = Address(
        Env.smtpFromEmail,
        Env.smtpFromName,
      )
      ..recipients.add(toEmail)
      ..subject = 'Reset your password - ${Env.smtpFromName}'
      ..html = _buildPasswordResetEmail(
        name: name,
        otp: otp,
      )
      ..text =
          '''
      Hello $name,

      We received a request to reset your password.

      Your password reset code is:

      $otp

      This code will expire in
      ${Env.emailVerificationExpiresMinutes} minutes.

      If you did not request a password reset,
      you can safely ignore this email.

      Never share this code with anyone.

      © ${DateTime.now().year} ${Env.smtpFromName}
      ''';

    await send(
      message,
      _smtpServer,
    );
  }

  String _buildPasswordResetEmail({
    required String name,
    required String otp,
  }) {
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">

      <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
      >

      <title>Reset Your Password</title>
    </head>

    <body
      style="
        margin:0;
        padding:0;
        background:#f4f7fb;
        font-family:Arial,Helvetica,sans-serif;
      "
    >

      <table
        width="100%"
        cellpadding="0"
        cellspacing="0"
        border="0"
        style="background:#f4f7fb;padding:40px 15px;"
      >

        <tr>
          <td align="center">

            <!-- Main Card -->
            <table
              width="100%"
              cellpadding="0"
              cellspacing="0"
              border="0"
              style="
                max-width:560px;
                background:#ffffff;
                border-radius:16px;
                overflow:hidden;
                box-shadow:0 8px 30px rgba(0,0,0,0.08);
              "
            >

              <!-- Header -->
              <tr>
                <td
                  align="center"
                  style="
                    background:#0d6efd;
                    padding:32px 25px;
                  "
                >

                  <div
                    style="
                      width:58px;
                      height:58px;
                      line-height:58px;
                      background:#ffffff;
                      border-radius:50%;
                      color:#0d6efd;
                      font-size:28px;
                      font-weight:bold;
                      margin:auto;
                    "
                  >
                    🔑
                  </div>

                  <h1
                    style="
                      margin:18px 0 5px;
                      color:#ffffff;
                      font-size:26px;
                      font-weight:700;
                    "
                  >
                    ${Env.smtpFromName}
                  </h1>

                  <p
                    style="
                      margin:0;
                      color:#dbeafe;
                      font-size:14px;
                    "
                  >
                    Secure password recovery
                  </p>

                </td>
              </tr>


              <!-- Content -->
              <tr>
                <td style="padding:38px 35px 30px;">

                  <h2
                    style="
                      margin:0 0 12px;
                      color:#111827;
                      font-size:24px;
                    "
                  >
                    Reset your password 🔐
                  </h2>

                  <p
                    style="
                      margin:0 0 24px;
                      color:#4b5563;
                      font-size:15px;
                      line-height:1.7;
                    "
                  >
                    Hello <strong>$name</strong>,
                    <br><br>

                    We received a request to reset the password
                    for your account. Use the verification code
                    below to continue.
                  </p>


                  <!-- OTP Box -->
                  <table
                    width="100%"
                    cellpadding="0"
                    cellspacing="0"
                    border="0"
                  >
                    <tr>
                      <td
                        align="center"
                        style="
                          background:#f0f6ff;
                          border:1px solid #d7e7ff;
                          border-radius:14px;
                          padding:25px 15px;
                        "
                      >

                        <p
                          style="
                            margin:0 0 10px;
                            color:#6b7280;
                            font-size:12px;
                            text-transform:uppercase;
                            letter-spacing:2px;
                            font-weight:bold;
                          "
                        >
                          Password Reset Code
                        </p>

                        <div
                          style="
                            color:#0d6efd;
                            font-size:38px;
                            font-weight:800;
                            letter-spacing:10px;
                            padding-left:10px;
                          "
                        >
                          $otp
                        </div>

                      </td>
                    </tr>
                  </table>


                  <!-- Expiration -->
                  <table
                    width="100%"
                    cellpadding="0"
                    cellspacing="0"
                    border="0"
                    style="margin-top:22px;"
                  >
                    <tr>
                      <td
                        style="
                          background:#fff8e6;
                          border:1px solid #ffe3a3;
                          border-radius:10px;
                          padding:14px 16px;
                        "
                      >

                        <p
                          style="
                            margin:0;
                            color:#8a5a00;
                            font-size:13px;
                            line-height:1.6;
                          "
                        >
                          ⏱️
                          <strong>This code expires in
                          ${Env.emailVerificationExpiresMinutes}
                          minutes.</strong>
                        </p>

                      </td>
                    </tr>
                  </table>


                  <!-- Security -->
                  <div style="margin-top:25px;">

                    <p
                      style="
                        margin:0;
                        color:#6b7280;
                        font-size:13px;
                        line-height:1.7;
                      "
                    >
                      🛡️ <strong>Security reminder</strong>
                      <br>

                      Never share this password reset code with
                      anyone. Our team will never ask you for
                      your OTP or password.
                    </p>

                  </div>


                  <!-- Warning -->
                  <table
                    width="100%"
                    cellpadding="0"
                    cellspacing="0"
                    border="0"
                    style="margin-top:22px;"
                  >
                    <tr>
                      <td
                        style="
                          background:#fff5f5;
                          border:1px solid #ffd6d6;
                          border-radius:10px;
                          padding:14px 16px;
                        "
                      >

                        <p
                          style="
                            margin:0;
                            color:#991b1b;
                            font-size:13px;
                            line-height:1.6;
                          "
                        >
                          ⚠️
                          If you did not request a password
                          reset, please ignore this email and
                          make sure your account remains secure.
                        </p>

                      </td>
                    </tr>
                  </table>


                  <p
                    style="
                      margin:28px 0 0;
                      color:#6b7280;
                      font-size:13px;
                      line-height:1.6;
                    "
                  >
                    For your security, never share this code
                    with anyone.
                  </p>

                </td>
              </tr>


              <!-- Footer -->
              <tr>
                <td
                  align="center"
                  style="
                    background:#f9fafb;
                    border-top:1px solid #eef0f3;
                    padding:22px 25px;
                  "
                >

                  <p
                    style="
                      margin:0;
                      color:#9ca3af;
                      font-size:12px;
                      line-height:1.6;
                    "
                  >
                    © ${DateTime.now().year} ${Env.smtpFromName}
                    <br>
                    This is an automated message.
                    Please do not reply.
                  </p>

                </td>
              </tr>

            </table>

          </td>
        </tr>

      </table>

    </body>
    </html>
    ''';
  }
}
