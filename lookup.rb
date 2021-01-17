def get_command_line_argument
    # ARGV is an array that Ruby defines for us,
    # which contains all the arguments we passed to it
    # when invoking the script from the command line.
    # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
    if ARGV.empty?
      puts "Usage: ruby lookup.rb <domain>"
      exit
    end
    ARGV.first
  end
  
  # `domain` contains the domain name we have to look up.
  domain = get_command_line_argument
  
  # File.readlines reads a file and returns an
  # array of string, where each element is a line
  # https://www.rubydoc.info/stdlib/core/IO:readlines
  dns_raw = File.readlines("zone")
  
  # parse_dns function to parse file data
  def parse_dns(dns_raw)
    dns_records = {}
    dns_raw.each do |line|
      arr = line.split(", ")
      if(arr[0] == "A" || arr[0] == "CNAME")
        dns_records[arr[1]] = {:type => arr[0], :target => arr[2].strip}
      end
    end
    
    return dns_records
  end

  # resolve function to find ip of domain
  def resolve(dns_records, lookup_chain, domain)
    value = dns_records[domain]
    if(value == nil)
      puts "Error: record not found for #{domain}"
      exit

    elsif(value[:type] == "A")
      lookup_chain.push(value[:target])
      return lookup_chain

    elsif(value[:type] == "CNAME")
      lookup_chain.push(value[:target])
      return resolve(dns_records, lookup_chain, value[:target])
      
    end
  end
  
  # To complete the assignment, implement `parse_dns` and `resolve`.
  # Remember to implement them above this line since in Ruby
  # you can invoke a function only after it is defined.
  # puts "hello"
  dns_records = parse_dns(dns_raw)
  lookup_chain = [domain]
  lookup_chain = resolve(dns_records, lookup_chain, domain)
  puts lookup_chain.join(" => ")