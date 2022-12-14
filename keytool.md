# KeyStore 和 TrustStore

KeyStore 和 TrustStore 是 JSSE 中使用的两种文件。这两种文件都使用 java 的 keytool 来管理，他们的不同主要在于用途和相应用途决定的内容的不同。

这两种文件在一个 SSL 认证场景中，KeyStore 用于服务器认证服务端，而 TrustStore 用于客户端认证服务器。

比如在客户端对服务器发起一次 HTTPS 请求时,服务器需要向客户端提供认证以便客户端确认这个服务器是否可信。这里，服务器向客户端提供的认证信息就是自身的证书和公钥，而这些信息，包括对应的私钥，服务器就是通过 KeyStore 来保存的。当服务器提供的证书和公钥到了客户端，客户端就要生成一个 TrustStore 文件保存这些来自服务器证书和公钥。

KeyStore 和 TrustStore 的不同，也主要是通过上面所描述的使用目的的不同来区分的，在 Java 中这两种文件都可以通过 keytool 来完成。不过因为其保存的信息的敏感度不同，KeyStore 文件通常需要密码保护。

正是因为 KeyStore 和 TrustStore 在 Java 中都可以通过 keytool 来管理的，所以在使用时多有混淆。记住以下几点，可以最大限度避免这些混淆:

* 如果要保存你自己的密码，秘钥和证书，应该使用 KeyStore，并且该文件要保持私密不外泄，不要传播该文件;

* 如果要保存你信任的来自他人的公钥和证书，应该使用 TrustStore，而不是 KeyStore;


```bash

##########################################################################

$ keytool
Key and Certificate Management Tool

Commands:

# Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA)
-genkeypair
Generates a key pair

#
-list
Lists entries in a keystore

# 导出证书
-exportcert
Exports certificate

# 打印证书
-printcert
Prints the content of a certificate




-certreq
Generates a certificate request

-changealias
Changes an entry\'s alias

-delete
Deletes an entry

-genseckey
Generates a secret key

-gencert
Generates certificate from a certificate request

-importcert
Imports a certificate or a certificate chain  导入证书或证书链

-importpass
Imports a password

-importkeystore
Imports one or all entries from another keystore

-keypasswd
Changes the key password of an entry

-printcertreq
Prints the content of a certificate request

-printcrl
Prints the content of a CRL file

-storepasswd
Changes the store password of a keystore

Use "keytool -command_name -help" for usage of command_name


##########################################################################


$ keytool -genkeypair -help
keytool -genkeypair [OPTION]...

Generates a key pair

Options:

-alias <alias>
alias name of the entry to process

-keyalg <keyalg>
key algorithm name

-keysize <keysize>
key bit size

-sigalg <sigalg>
signature algorithm name

-destalias <destalias>
destination alias

-dname <dname>
distinguished name

-startdate <startdate>
certificate validity start date/time

-ext <value>
X.509 extension

-validity <valDays>
validity number of days

-keypass <arg>
key password

-keystore <keystore>
keystore name

-storepass <arg>
keystore password

-storetype <storetype>
keystore type

-providername <providername>
provider name

-providerclass <providerclass>
provider class name

-providerarg <arg>
provider argument

-providerpath <pathlist>
provider classpath

-v
verbose output

-protected
password through protected mechanism

Use "keytool -help" for all available commands





$ keytool -genkeypair -alias config -keyalg RSA -keypass config -keystore config.keystore -storepass config -v

$ keytool -genkeypair -alias config -keyalg RSA -keypass config -keystore config.keystore -storepass config -storetype pkcs12 -v

What is your first and last name?
  [Unknown]:  www.alauda.io
What is the name of your organizational unit?
  [Unknown]:  dataservices
What is the name of your organization?
  [Unknown]:  alauda
What is the name of your City or Locality?
  [Unknown]:  wuhanshi
What is the name of your State or Province?
  [Unknown]:  hubeisheng
What is the two-letter country code for this unit?
  [Unknown]:  CN
Is CN=www.alauda.io, OU=dataservices, O=alauda, L=wuhanshi, ST=hubeisheng, C=CN correct?
  [no]:  yes






##########################################################################



$ keytool -genseckey -help
keytool -genseckey [OPTION]...

Generates a secret key

Options:

-alias <alias>
alias name of the entry to process

-keypass <arg>
key password

-keyalg <keyalg>
key algorithm name

-keysize <keysize>
key bit size

-keystore <keystore>
keystore name

-storepass <arg>
keystore password

-storetype <storetype>
keystore type

-providername <providername>
provider name

-providerclass <providerclass>
provider class name

-providerarg <arg>
provider argument

-providerpath <pathlist>
provider classpath

-v
verbose output

-protected
password through protected mechanism

Use "keytool -help" for all available commands



keytool -genseckey -alias config -keypass config -keyalg RSA -keystore config.keystore -storepass config -storetype pkcs12 -v












##########################################################################

$ keytool -list -help
keytool -list [OPTION]...

Lists entries in a keystore

Options:

 -rfc                            output in RFC style
 -alias <alias>                  alias name of the entry to process
 -keystore <keystore>            keystore name
 -storepass <arg>                keystore password
 -storetype <storetype>          keystore type
 -providername <providername>    provider name
 -providerclass <providerclass>  provider class name
 -providerarg <arg>              provider argument
 -providerpath <pathlist>        provider classpath
 -v                              verbose output
 -protected                      password through protected mechanism

Use "keytool -help" for all available commands



keytool -list -keystore config.keystore -storepass config -storetype pkcs12 -v
keytool -list -alias config -keystore config.keystore -storepass config -storetype pkcs12 -v


##########################################################################



$ keytool -exportcert -help
keytool -exportcert [OPTION]...

Exports certificate

Options:

 -rfc                            output in RFC style
 -alias <alias>                  alias name of the entry to process
 -file <filename>                output file name
 -keystore <keystore>            keystore name
 -storepass <arg>                keystore password
 -storetype <storetype>          keystore type
 -providername <providername>    provider name
 -providerclass <providerclass>  provider class name
 -providerarg <arg>              provider argument
 -providerpath <pathlist>        provider classpath
 -v                              verbose output
 -protected                      password through protected mechanism

Use "keytool -help" for all available commands


keytool -exportcert -alias config -file config.crt -keystore config.keystore -storepass config -storetype pkcs12 -v







##########################################################################


$ keytool -printcert -help
keytool -printcert [OPTION]...

Prints the content of a certificate

Options:

 -rfc                        output in RFC style
 -file <filename>            input file name
 -sslserver <server[:port]>  SSL server host and port
 -jarfile <filename>         signed jar file
 -v                          verbose output

Use "keytool -help" for all available commands


keytool -printcert -file config.crt -v





##########################################################################



$ keytool -certreq -help
keytool -certreq [OPTION]...

Generates a certificate request

Options:

 -alias <alias>                  alias name of the entry to process
 -sigalg <sigalg>                signature algorithm name
 -file <filename>                output file name
 -keypass <arg>                  key password
 -keystore <keystore>            keystore name
 -dname <dname>                  distinguished name
 -storepass <arg>                keystore password
 -storetype <storetype>          keystore type
 -providername <providername>    provider name
 -providerclass <providerclass>  provider class name
 -providerarg <arg>              provider argument
 -providerpath <pathlist>        provider classpath
 -systemlineendings              use system line endings rather than CRLF to terminate output
 -v                              verbose output
 -protected                      password through protected mechanism

Use "keytool -help" for all available commands


keytool -certreq -alias config -sigalg RSA -file config.csr -keypass config -keystore config.keystore 




##########################################################################



##########################################################################


##########################################################################











```

