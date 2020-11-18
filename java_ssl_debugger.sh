#!/bin/bash

helpFunction() {
    echo ""
    echo "Usage: $0 -h hostname -p port -k keyStorePath"
    echo -e "\t-h Description of what is hostname"
    echo -e "\t-p Description of what is port"
    echo -e "\t-k Description of what is keyStorePath"
    exit 1 # Exit script after printing help
}

while getopts "h:p:k:" opt; do
    case "$opt" in
    h) hostname="$OPTARG" ;;
    p) port="$OPTARG" ;;
    k) keyStorePath="$OPTARG" ;;
    ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
    esac
done

echo "hostname $hostname"
echo "port $port"
echo "keyStorePath $keyStorePath"

if which java >/dev/null; then
    echo "java exist"
else
    echo "java does not exist, please install java first. Just do a google: how to install java in mac"
fi

rm SSLPoke.java

echo 'import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.*;

/** Establish a SSL connection to a host and port, writes a byte and
 * prints the response. See
 * http://confluence.atlassian.com/display/JIRA/Connecting+to+SSL+services
 */
public class SSLPoke {
    public static void main(String[] args) {
		if (args.length != 2) {
			System.out.println("Usage: "+SSLPoke.class.getName()+" <host> <port>");
			System.exit(1);
		}
		try {
			SSLSocketFactory sslsocketfactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
			SSLSocket sslsocket = (SSLSocket) sslsocketfactory.createSocket(args[0], Integer.parseInt(args[1]));

			InputStream in = sslsocket.getInputStream();
			OutputStream out = sslsocket.getOutputStream();

			// Write a test byte to get a reaction :)
			out.write(1);

			while (in.available() > 0) {
				System.out.print(in.read());
			}
			System.out.println("Successfully connected");

		} catch (Exception exception) {
			exception.printStackTrace();
		}
	}
}
' >>SSLPoke.java

javac SSLPoke.java

if [ -z "$hostname" ]; then
    echo "Please enter hostname, for example, google.com"
    read hostname
fi

if [ -z "$port" ]; then
    echo "Please enter port, for example, 443"
    read port
fi

# echo "Please keystore path"
# read keystore

# echo "Please truststore path"
# read truststore
if [ "$keyStorePath" ]; then
    keyV="-Djavax.net.ssl.keyStore=$keyStorePath"
fi

java -Djavax.net.ssl.keyStore=$keyStorePath -Djavax.net.debug=ssl,handshake -Djava.security.debug=access:stack SSLPoke $hostname $port
