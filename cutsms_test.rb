#计时开始
t1 = Time.now
p t1

input = "D:/ruby/SMS-Spam-Classifier/data/data_1w.txt"
output = "D:/ruby/SMS-Spam-Classifier/data/data_test.txt"

file_input = File.open(input)
file_output = File.open(output,"w")

max_matches = 10000 #print out the max line
matches = 0
str = ""

file_input.each_line do |line|
  
  if matches >= max_matches
     break     
  end
  
  if matches >= 8000
    
    sline = line.split(/\t/)
    str = str + "#{sline[0]}\t#{sline[2]}"
    
  end

  matches += 1
end 
#puts str  #输出str

file_output.write(str)

file_output.close
file_input.close

#计时结束
t2 = Time.now
p t2

puts "总共耗时：#{t2 - t1}s"