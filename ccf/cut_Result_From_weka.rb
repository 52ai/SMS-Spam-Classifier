#encoding=utf-8
#��ʱ��ʼ
t1 = Time.now
p t1

input = "D:/ruby/SMS-Spam-Classifier/ccf/result_test_20w_NBTrees.txt"
output = "D:/ruby/SMS-Spam-Classifier/ccf/finalSubmit.txt"

file_input = File.open(input)
file_output = File.open(output,"w")

max_matches = 200000 #print out the max line
matches = 0
str = ""

file_input.each_line do |line|
  
  if matches >= max_matches
     break     
  end
  if line.include?("yes")
    n2 = 1
  else 
    n2 =0
  end
  n1 = matches + 800001
  
  str = str + "#{n1},#{n2}\n"  
  #puts str
  matches += 1
end 
#puts str  

file_output.write(str)

file_output.close
file_input.close


t2 = Time.now
p t2

puts "Time consuming: #{t2 - t1}s"