Need to download protoc [windows 10](https://github.com/protocolbuffers/protobuf/releases/)

Useful plugins:
<ul>
<li>Protobuf Support</li>
<li>GenProtobuf</li>
</ul>

In order to generate dart proto file, make sure you install the dart proto plugin via: 
[source](https://grpc.io/docs/languages/dart/quickstart/#protocol-buffers-v3)

```
$ pub global activate protoc_plugin
```

And then add the installed plugin to your system path.  For Windows 10, it is installed somewhere like:

```buildoutcfg
c:\Users\[youruser]\AppData\Roaming\Pub\Cache\bin\protoc-gen-dart.bat
```
There are [reports](https://github.com/grpc/grpc-dart/issues/71#issuecomment-375925210) saying that you need to explicitly add the plugin in the protoc command.. YMMV

Finally, to generate dart proto file, run this command:
```commandline
# Note that you can use "." for current directory
protoc -I="<dir where proto file is>" --dart_out="<dir for output>" <proto file name>

# For example: 
protoc -I="./proto/lib" --dart_out="./proto/lib" --python_out="./proto/lib" article.proto

# For mac:
protoc --dart_out="." --python_out="." article.proto
```

You also need to generate timestamp proto file for dart:
```
protoc -I="C:\bin\protoc-3.12.3-win64\include\google\protobuf" --dart_out="./proto/lib/google/protobuf/" timestamp.proto
```
