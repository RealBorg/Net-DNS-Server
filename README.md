# Net::DNS::Server

A simple DNS server implementation in Perl.

## Overview

`Net::DNS::Server` is a lightweight DNS server that reads DNS records from a text file and responds to DNS queries. It supports basic DNS record types like A, MX, NS, and SOA.

## Features

- Reads DNS records from a file (`/etc/dns.txt` by default).
- Supports UDP protocol for DNS queries.
- Handles basic DNS query types: A, MX, NS, SOA.
- Provides logging of DNS queries and responses.

## Installation

### Prerequisites

- Perl 5.10 or higher
- Net::DNS module
- IO::Socket::IP module
- File::Slurp module
- List::Util module

You can install these modules using CPAN:

    cpanm Net::DNS IO::Socket::IP File::Slurp List::Util

### Setup

1. **Clone the repository:**

        git clone [YOUR_GIT_URL_HERE]
        cd Net::DNS::Server

2. **Edit Configuration:**
   - Open the script and adjust the `DNSTXT`, `LocalAddr`, `LocalPort`, and `Proto` parameters as needed.

3. **Run the Server:**

        perl Net::DNS::Server.pm

## Usage

### Running the Server

- Start the server by executing the Perl script. It will listen for DNS queries on the specified port and address.

### DNS Record File Format

The DNS records should be in a text file (`/etc/dns.txt` by default). Each line should represent a valid DNS record in a format that `Net::DNS::RR->new()` can understand. Example:

    example.com. IN A 192.0.2.1

### Logging

Queries and responses are logged to STDOUT in the following format:

    Net::DNS::Server YYYY-MM-DDTHH:MM:SS <peerhost> <ID> <qname> <qclass> <qtype> <rcode>

## Contributing

Contributions are welcome! Here's how you can contribute:

- **Fork the project**
- **Create your feature branch** (`git checkout -b feature/AmazingFeature`)
- **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
- **Push to the branch** (`git push origin feature/AmazingFeature`)
- **Open a pull request**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Thanks to the authors of Net::DNS, IO::Socket::IP, File::Slurp, and List::Util for their excellent libraries.

## Contact

For any issues or feature requests, please open an issue in the repository or reach out via GitHub
