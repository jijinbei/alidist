# Monitoring v3.19.10 — ALICE O2 Monitoring library
# Source: monitoring.sh
{ lib, stdenv, fetchFromGitHub, cmake, ninja, boost, curl, libinfologger }:

stdenv.mkDerivation rec {
  pname = "monitoring";
  version = "3.19.10";

  src = fetchFromGitHub {
    owner = "AliceO2Group";
    repo = "Monitoring";
    rev = "v${version}";
    hash = "sha256-dN3pshPz0AT/PR3sWaKwTyonb8CD3WLZ/BeMAMqBlkI=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ boost curl libinfologger ];

  # Fix deprecated Boost.Asio API (resolver::query/iterator removed in newer Boost)
  postPatch = ''
    # Fix UDP.cxx
    sed -i 's|boost::asio::ip::udp::resolver::query query(boost::asio::ip::udp::v4(), hostname, std::to_string(port));|auto results = resolver.resolve(boost::asio::ip::udp::v4(), hostname, std::to_string(port));|' src/Transports/UDP.cxx
    sed -i '/boost::asio::ip::udp::resolver::iterator resolverInerator = resolver.resolve(query);/d' src/Transports/UDP.cxx
    sed -i 's|mEndpoint = \*resolverInerator;|mEndpoint = *results.begin();|' src/Transports/UDP.cxx

    # Fix TCP.h — replace iterator member with endpoint
    sed -i 's|boost::asio::ip::tcp::resolver::iterator mEndpoint;|boost::asio::ip::tcp::endpoint mEndpoint;|' src/Transports/TCP.h

    # Fix TCP.cxx — replace deprecated query/iterator with modern API
    cat > src/Transports/TCP.cxx.patch << 'PATCH'
--- a/src/Transports/TCP.cxx
+++ b/src/Transports/TCP.cxx
@@ -33,14 +33,13 @@
 TCP::TCP(const std::string& hostname, int port) : mSocket(mIoService)
 {
   boost::asio::ip::tcp::resolver resolver(mIoService);
-  boost::asio::ip::tcp::resolver::query query(hostname, std::to_string(port));
-  boost::asio::ip::tcp::resolver::iterator resolverIterator = resolver.resolve(query);
+  auto results = resolver.resolve(hostname, std::to_string(port));

-  boost::asio::ip::tcp::resolver::iterator end;
   boost::system::error_code error = boost::asio::error::host_not_found;
-  while (error && resolverIterator != end) {
+  for (auto it = results.begin(); it != results.end() && error; ++it) {
     mSocket.close();
-    mSocket.connect(*resolverIterator++, error);
+    mSocket.connect(it->endpoint(), error);
   }
   if (error) {
     throw MonitoringException("TCP connection", error.message());
PATCH
    sed -i \
      -e 's|boost::asio::ip::tcp::resolver::query query(hostname, std::to_string(port));|auto results = resolver.resolve(hostname, std::to_string(port));|' \
      -e '/boost::asio::ip::tcp::resolver::iterator resolverIterator = resolver.resolve(query);/d' \
      -e '/boost::asio::ip::tcp::resolver::iterator end;/d' \
      -e 's|while (error \&\& resolverIterator != end) {|for (auto it = results.begin(); it != results.end() \&\& error; ++it) {|' \
      -e 's|mSocket.connect(\*resolverIterator++, error);|mSocket.connect(it->endpoint(), error);|' \
      src/Transports/TCP.cxx
    rm -f src/Transports/TCP.cxx.patch
  '';

  cmakeFlags = [
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    # Disable optional backends not needed for core build
    "-DO2_MONITORING_CONTROL_ENABLE=0"
    "-DO2_MONITORING_KAFKA_ENABLE=0"
  ];

  meta = with lib; {
    description = "ALICE O2 Monitoring library";
    homepage = "https://github.com/AliceO2Group/Monitoring";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
