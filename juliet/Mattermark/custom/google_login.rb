require 'google/api_client'
require 'google_drive'

# @client = Google::APIClient.new#(application_name: 'Google Drive Ruby test', application_version: '0.0.1')
#
# CLIENT_SECRETS = Google::APIClient::ClientSecrets.load('client_secret.json')
# authorization = CLIENT_SECRETS.to_authorization
# authorization.scope =
# "https://www.googleapis.com/auth/drive " +
# "https://docs.google.com/feeds/ " +
# "https://docs.googleusercontent.com/ " +
# "https://spreadsheets.google.com/feeds/"
# # You can then use this with an API client, e.g.:
# # client.authorization = authorization
#
# # key = Google::APIClient::KeyUtils.load_from_pkcs12(
# #     'path to your p12 key file',
# #     'your secret here')
# #
# # asserter = Google::APIClient::JWTAsserter.new(
# #     'service account id here',
# #     ['https://www.googleapis.com/auth/drive', G],
# #     key
# # )
# @client.authorization = authorization
# @session = GoogleDrive.login_with_oauth(@client.authorization.access_token)


# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
session = GoogleDrive.saved_session("auth.json")

# Gets list of remote files.
# session.files.each do |file|
#   p file.title
# end

# Uploads a local file.
# session.upload_from_file("/path/to/hello.txt", "hello.txt", convert: false)

# Downloads to a local file.
# file = session.file_by_title("hello.txt")
# file.download_to_file("/path/to/hello.txt")

# Updates content of the remote file.
# file.update_from_file("/path/to/hello.txt")


# 13ToOJaoVgfALm16fEkJrECUkwDpVjfUpbXeXCI4f1sU
ws = session.spreadsheet_by_key("13ToOJaoVgfALm16fEkJrECUkwDpVjfUpbXeXCI4f1sU").worksheets[1]

ws[2, 2] = "bar"
ws.save
