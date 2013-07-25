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
	#puts maildir.list(:new).first.data
	date = singlemail.data.scan(/(Delivery-date|Date):(.*[^-a-zA-Z1-9_.])?/i)
	print date.inspect
	ctime = Time.parse(date[1].to_s)
#	puts ctime
	imap.append(imap_dir,singlemail.data,nil,ctime)
	puts "mesage added #{index+1} / #{maildir.list(:cur).size}"
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
