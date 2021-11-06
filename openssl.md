# OpenSSL

```bash
$ openssl help

Standard commands
支持的标准命令，即伪命令
asn1parse         ca                certhash          ciphers
crl               crl2pkcs7         dgst              dh
dhparam           dsa               dsaparam          ec
ecparam           enc               errstr            gendh
gendsa            genpkey           genrsa            nseq
ocsp              passwd            pkcs12            pkcs7
pkcs8             pkey              pkeyparam         pkeyutl
prime             rand              req               rsa
rsautl            s_client          s_server          s_time
sess_id           smime             speed             spkac
ts                verify            version           x509

Message Digest commands (see the `dgst' command for more details)
指定"dgst"命令时即单向加密支持的算法，实际上支持更多的算法，具体见dgst命令
gost-mac          md4               md5               md_gost94
ripemd160         sha1              sha224            sha256
sha384            sha512            streebog256       streebog512
whirlpool

Cipher commands (see the `enc' command for more details)
指定对称加密"enc"时支持的对称加密算法
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb
aes-256-cbc       aes-256-ecb       base64            bf
bf-cbc            bf-cfb            bf-ecb            bf-ofb
camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  camellia-192-ecb
camellia-256-cbc  camellia-256-ecb  cast              cast-cbc
cast5-cbc         cast5-cfb         cast5-ecb         cast5-ofb
chacha            des               des-cbc           des-cfb
des-ecb           des-ede           des-ede-cbc       des-ede-cfb
des-ede-ofb       des-ede3          des-ede3-cbc      des-ede3-cfb
des-ede3-ofb      des-ofb           des3              desx
rc2               rc2-40-cbc        rc2-64-cbc        rc2-cbc
rc2-cfb           rc2-ecb           rc2-ofb           rc4
rc4-40
$
```






## ca


用于签署证书请求、生成吊销列表 CRL 以及维护已颁发证书列表和这些证书状态的数据库。

证书请求文件使用 CA 的私钥签署之后就是证书，签署之后将证书发给申请者就是颁发证书。在签署时，为了保证证书的完整性和一致性，还应该对签署的证书生成数字摘要，即使用单向加密算法。

openssl ca命令对配置文件(默认为`/etc/pki/tls/openssl.cnf`)的依赖性非常强，在配置文件中指定了签署证书时所需文件的结构。


## dgst

dgst, sha, sha1, mdc2, ripemd160, sha224, sha256, sha384, sha512, md2, md4, md5, dss1 - message digests

该伪命令是单向加密工具，用于生成文件的摘要信息，也可以进行数字签名，验证数字签名。

首先要明白的是，数字签名的过程是计算出数字摘要，然后使用私钥对数字摘要进行签名，而摘要是使用 md5、sha512 等算法计算得出的，理解了这一点，openssl dgst 命令的用法就完全掌握了。



## dhparam 和 dh 以及 gendh

openssl dhparam 用于生成和管理 dh 文件。dh(Diffie-Hellman) 是著名的密钥交换协议，或称为密钥协商协议，它可以保证通信双方安全地交换密钥。但注意，它不是加密算法，所以不提供加密功能，仅仅只是保护密钥交换的过程。在 openvpn中就使用了该交换协议。

openssl dhparam 命令集合了老版本的 openssl dh 和 openssl gendh，后两者可能已经失效了，即使存在也仅表示未来另有用途。


## enc

enc - symmetric cipher routines

The symmetric cipher commands allow data to be encrypted or decrypted using various block and stream ciphers using keys based on passwords or explicitly provided. Base64 encoding or decoding can also be performed either by itself or in addition to the encryption or decryption.

对称加密工具。





## genrsa

man genrsa

genrsa - generate an RSA private key

genrsa 用于生成 RSA 私钥，不会生成公钥，因为公钥提取自私钥，如果需要查看公钥或生成公钥，可以使用 openssl rsa 命令。





## passwd

passwd - update user's authentication tokens

该伪命令用于生成加密的密码。














## rand

rand - generate pseudo-random bytes

生成伪随机数。






## req

伪命令 req 大致有 3 个功能：生成证书请求文件、验证证书请求文件和创建根CA。


## rsa 和 pkey

man rsa

rsa - RSA key processing tool

pkey - public or private key processing tool

openssl rsa 和 openssl pkey 分别是 RSA 密钥的处理工具和通用非对称密钥处理工具，它们用法基本一致。

它们的用法很简单，基本上就是输入和输出私钥或公钥的作用。



## rsautl 和 pkeyutl

rsautl - RSA utility

The rsautl command can be used to sign, verify, encrypt and decrypt data using the RSA algorithm.

pkeyutl - public key algorithm utility

The pkeyutl command can be used to perform public key operations using any supported algorithm.

rsautl 是 rsa 的工具，相当于 rsa、dgst 的部分功能集合，可用于生成数字签名、验证数字签名、加密和解密文件。

pkeyutl 是非对称加密的通用工具，大体上和 rsautl 的用法差不多。






## speed

speed - test library performance

测试加密算法的性能。

* spkac
* ts
* verify
* version

## x509

主要用于输出证书信息，也能够签署证书请求文件、自签署、转换证书格式等。

openssl x509 工具不会使用 openssl 配置文件中的设定，而是完全需要自行设定或者使用该伪命令的默认值，它就像是一个完整的小型的 CA 工具箱。











