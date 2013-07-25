mail_dir=ARGV[0]
imap_host=ARGV[1]
imap_user=ARGV[2]
imap_pass=ARGV[3]
imap_dir=ARGV[4]

puts mail_dir
puts imap_host
puts imap_user
puts imap_pass
puts imap_dir
require 'maildir'
require 'net/imap'
#require 'mail'
require 'time'
#Create object
 
puts  "maildir"
maildir = Maildir.new(mail_dir, false); #avoid creating new maildir if not exist
#maildir.serializer = Maildir::Serializer::Mail.new
puts "before IMAP"
imap = Net::IMAP.new('imap.gmail.com',993,true)
puts "before auth"
puts imap.login(imap_user, imap_pass)
puts "auth done"

begin
	puts imap.examine(imap_dir)
rescue
	puts imap.create(imap_dir)
ensure
	puts imap.examine(imap_dir)
end

maildir.list(:new).each do |singlemail|
	puts maildir.list(:new).first.data
	date = singlemail.data.scan(/Delivery-date:(.*[^-a-zA-Z1-9_.])?/i)
	puts date

	puts "DATE IS HERE"

	puts "add message\r\n"
	ctime = Time.parse(date.to_s)
	puts ctime
	imap.append(imap_dir,singlemail.data,nil,ctime)
	puts "mesage added"
end
	
puts "done"
exit

