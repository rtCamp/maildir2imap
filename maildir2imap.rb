mail_dir=ARGV[0]
imap_host=ARGV[1]
imap_user=ARGV[2]
imap_pass=ARGV[3]
imap_dir=ARGV[4]

puts "Maildir: #{mail_dir}"
puts "IMAP host: '#{imap_host}'"
puts "IMAP user: '#{imap_user}'"
puts "IMAP password: '#{imap_pass}'"
puts "IMAP dir: '#{imap_dir}'"
require 'maildir'
require 'net/imap'
require 'time'
#Create object
puts  "maildir"
maildir = Maildir.new(mail_dir, false); #avoid creating new maildir if not exist
#maildir.serializer = Maildir::Serializer::Mail.new
puts "before IMAP"
imap = Net::IMAP.new('imap.gmail.com',993,true)
puts "before auth"
imap.login(imap_user, imap_pass)
puts "auth done"

begin
  imap.examine(imap_dir)
rescue
  imap.create(imap_dir)
ensure
  imap.examine(imap_dir)
end

puts "moving cur"
maildir.list(:cur).each_with_index do |singlemail, index|
  # puts maildir.list(:new).first.data
  print singlemail.filename
  print " "
  date = singlemail.data.scan(/^(Delivery-date|Date):(.*[^-a-zA-Z1-9_.])?/i)
  print date[0].inspect
  begin
    ctime = Time.parse(date[0][1].to_s)
    begin
      imap.append(imap_dir,singlemail.data,nil,ctime)
      puts " message added #{index+1} / #{maildir.list(:cur).size}"
      # Uncomment the following line to delete messages after uploading them.
      # ONLY DO THIS IF YOU'RE SURE!
      # singlemail.destroy
    rescue
      puts " could not add message (IMAP issue) #{index+1} / #{maildir.list(:cur).size}"
    end
  rescue NoMethodError
    puts " could not add message (could not parse date) #{index+1} / #{maildir.list(:cur).size}"
  end
end

puts "moving new"
maildir.list(:new).each_with_index do |singlemail, index|
        #puts maildir.list(:new).first.data
        date = singlemail.data.scan(/Delivery-date:(.*[^-a-zA-Z1-9_.])?/i)
        ctime = Time.parse(date.to_s)
 #       puts ctime
        imap.append(imap_dir,singlemail.data,nil,ctime)
        puts "mesage added #{index+1} / #{maildir.list(:new).size}"
end
puts "done"
exit
