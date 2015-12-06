#encoding: utf-8
#require "D:/ruby/SMS-Spam-Classifier/NavieBayes/naive_bayes"

require 'pp'

require 'rubygems'
require "bundler/setup"
require 'stemmer'

class NaiveBayes

  # provide a list of categories for this classifier
  def initialize(categories)
    # keeps a hash of word count for each category
    @words = Hash.new   
    @total_words = 0    
    # keeps a hash of number of documents trained for each category
    @categories_documents = Hash.new    
    @total_documents = 0
    @threshold = 1.5
    
    # keeps a hash of number of number of words in each category
    @categories_words = Hash.new
    
    categories.each { |category|         
      @words[category] = Hash.new         
      @categories_documents[category] = 0
      @categories_words[category] = 0
    }
  end

  # train the document
  def train(category, document)
    word_count(document).each do |word, count|
      @words[category][word] ||= 0
      @words[category][word] += count
      @total_words += count
      @categories_words[category] += count
    end
    @categories_documents[category] += 1
    @total_documents += 1
  end

  # find the probabilities for each category and return a hash
  def probabilities(document)
    probabilities = Hash.new
    @words.each_key {|category| 
      probabilities[category] = probability(category, document)
    }
    return probabilities
  end

  # classfiy the document into one of the categories
  def classify(document, default='unknown')
    sorted = probabilities(document).sort {|a,b| a[1]<=>b[1]}
    best,second_best = sorted.pop, sorted.pop
    return best[0] if best[1]/second_best[1] > @threshold
    return default
  end

  def prettify_probabilities(document)
    probs = probabilities(document).sort {|a,b| a[1]<=>b[1]}
    totals = 0
    pretty = Hash.new
    probs.each { |prob| totals += prob[1]}
    probs.each { |prob| pretty[prob[0]] = "#{prob[1]/totals * 100}%"}
    return pretty
  end

  private

  # the probability of a word in this category
  # uses a weighted probability in order not to have zero probabilities
  def word_probability(category, word)
    (@words[category][word.stem].to_f + 1)/@categories_words[category].to_f
  end

  # the probability of a document in this category
  # this is just the cumulative multiplication of all the word probabilities for this category
  def doc_probability(category, document)
    doc_prob = 1
    word_count(document).each { |word| doc_prob *= word_probability(category, word[0]) }
    return doc_prob
  end

  # the probability of a category
  # this is the probability that any random document being in this category
  def category_probability(category)
    @categories_documents[category].to_f/@total_documents.to_f
  end

  # the un-normalized probability of that this document belongs to this category
  def probability(category, document)
    doc_probability(category, document) * category_probability(category)
  end

  # get a hash of the number of times a word appears in any document
  def word_count(document)
    words = document.gsub(/[^\w\s]/,"").split
    d = Hash.new
    words.each do |word|
      word.downcase! 
      key = word.stem
      unless COMMON_WORDS.include?(word) # remove common words
        d[key] ||= 0
        d[key] += 1
      end
    end
    return d
  end 


  COMMON_WORDS = ['a','able','about','above','abroad','according','accordingly','across','actually','adj','after','afterwards','again','against','ago','ahead','ain\'t','all','allow','allows','almost','alone','along','alongside','already','also','although','always','am','amid','amidst','among','amongst','an','and','another','any','anybody','anyhow','anyone','anything','anyway','anyways','anywhere','apart','appear','appreciate','appropriate','are','aren\'t','around','as','a\'s','aside','ask','asking','associated','at','available','away','awfully','b','back','backward','backwards','be','became','because','become','becomes','becoming','been','before','beforehand','begin','behind','being','believe','below','beside','besides','best','better','between','beyond','both','brief','but','by','c','came','can','cannot','cant','can\'t','caption','cause','causes','certain','certainly','changes','clearly','c\'mon','co','co.','com','come','comes','concerning','consequently','consider','considering','contain','containing','contains','corresponding','could','couldn\'t','course','c\'s','currently','d','dare','daren\'t','definitely','described','despite','did','didn\'t','different','directly','do','does','doesn\'t','doing','done','don\'t','down','downwards','during','e','each','edu','eg','eight','eighty','either','else','elsewhere','end','ending','enough','entirely','especially','et','etc','even','ever','evermore','every','everybody','everyone','everything','everywhere','ex','exactly','example','except','f','fairly','far','farther','few','fewer','fifth','first','five','followed','following','follows','for','forever','former','formerly','forth','forward','found','four','from','further','furthermore','g','get','gets','getting','given','gives','go','goes','going','gone','got','gotten','greetings','h','had','hadn\'t','half','happens','hardly','has','hasn\'t','have','haven\'t','having','he','he\'d','he\'ll','hello','help','hence','her','here','hereafter','hereby','herein','here\'s','hereupon','hers','herself','he\'s','hi','him','himself','his','hither','hopefully','how','howbeit','however','hundred','i','i\'d','ie','if','ignored','i\'ll','i\'m','immediate','in','inasmuch','inc','inc.','indeed','indicate','indicated','indicates','inner','inside','insofar','instead','into','inward','is','isn\'t','it','it\'d','it\'ll','its','it\'s','itself','i\'ve','j','just','k','keep','keeps','kept','know','known','knows','l','last','lately','later','latter','latterly','least','less','lest','let','let\'s','like','liked','likely','likewise','little','look','looking','looks','low','lower','ltd','m','made','mainly','make','makes','many','may','maybe','mayn\'t','me','mean','meantime','meanwhile','merely','might','mightn\'t','mine','minus','miss','more','moreover','most','mostly','mr','mrs','much','must','mustn\'t','my','myself','n','name','namely','nd','near','nearly','necessary','need','needn\'t','needs','neither','never','neverf','neverless','nevertheless','new','next','nine','ninety','no','nobody','non','none','nonetheless','noone','no-one','nor','normally','not','nothing','notwithstanding','novel','now','nowhere','o','obviously','of','off','often','oh','ok','okay','old','on','once','one','ones','one\'s','only','onto','opposite','or','other','others','otherwise','ought','oughtn\'t','our','ours','ourselves','out','outside','over','overall','own','p','particular','particularly','past','per','perhaps','placed','please','plus','possible','presumably','probably','provided','provides','q','que','quite','qv','r','rather','rd','re','really','reasonably','recent','recently','regarding','regardless','regards','relatively','respectively','right','round','s','said','same','saw','say','saying','says','second','secondly','see','seeing','seem','seemed','seeming','seems','seen','self','selves','sensible','sent','serious','seriously','seven','several','shall','shan\'t','she','she\'d','she\'ll','she\'s','should','shouldn\'t','since','six','so','some','somebody','someday','somehow','someone','something','sometime','sometimes','somewhat','somewhere','soon','sorry','specified','specify','specifying','still','sub','such','sup','sure','t','take','taken','taking','tell','tends','th','than','thank','thanks','thanx','that','that\'ll','thats','that\'s','that\'ve','the','their','theirs','them','themselves','then','thence','there','thereafter','thereby','there\'d','therefore','therein','there\'ll','there\'re','theres','there\'s','thereupon','there\'ve','these','they','they\'d','they\'ll','they\'re','they\'ve','thing','things','think','third','thirty','this','thorough','thoroughly','those','though','three','through','throughout','thru','thus','till','to','together','too','took','toward','towards','tried','tries','truly','try','trying','t\'s','twice','two','u','un','under','underneath','undoing','unfortunately','unless','unlike','unlikely','until','unto','up','upon','upwards','us','use','used','useful','uses','using','usually','v','value','various','versus','very','via','viz','vs','w','want','wants','was','wasn\'t','way','we','we\'d','welcome','well','we\'ll','went','were','we\'re','weren\'t','we\'ve','what','whatever','what\'ll','what\'s','what\'ve','when','whence','whenever','where','whereafter','whereas','whereby','wherein','where\'s','whereupon','wherever','whether','which','whichever','while','whilst','whither','who','who\'d','whoever','whole','who\'ll','whom','whomever','who\'s','whose','why','will','willing','wish','with','within','without','wonder','won\'t','would','wouldn\'t','x','y','yes','yet','you','you\'d','you\'ll','your','you\'re','yours','yourself','yourselves','you\'ve','z','zero']  
end

b = NaiveBayes.new(["interesting", "not_interesting"])

b.train("interesting","'Human error' hits Google search Google's search service has been hit by technical problems, with users unable to access search results. For a period on Saturday, all search results were flagged as potentially harmful, with users warned that the site \"may harm your computer\". Users who clicked on their preferred search result were advised to pick another one. Google attributed the fault to human error and said most users were affected for about 40 minutes. \"What happened? Very simply, human error,\" wrote Marissa Mayer, vice president, search products and user experience, on the Official Google Blog. The internet search engine works with stopbadware.org to ascertain which sites install malicious software on people's computers and merit a warning. Stopbadware.org investigates consumer complaints to decide which sites are dangerous. The list of malevolent sites is regularly updated and handed to Google. When Google updated the list on Saturday, it mistakenly flagged all sites as potentially dangerous. \"We will carefully investigate this incident and put more robust file checks in place to prevent it from happening again,\" Ms Mayer wrote.")

b.train("interesting", "Mixed reaction to digital plans Reaction to the publication of Lord Carter's interim report on Digital Britain has been swift. The 86-page report sets out ambitious targets for the government to make broadband ubiquitous across the UK, reform radio spectrum, and sort out public broadcasting. Some have been positive about its conclusions but opposition politicians criticised the wide-ranging report, saying it was light on specifics. \"We're very disappointed,\" said Jeremy Hunt, shadow culture minister. \"We thought the report was going to contain a strategy,\" he said. \"In France and Germany they are laying fibre, in Japan they already have it. In Britain the average broadband speed is 3.6Mb so what [Andy Burnham] is talking about is getting half the current speed.\" Don Foster, the Lib Dem's culture, media and sport spokesman, said the report was \"bitterly disappointing\". \"We've spent lots of money on reviews, but all we now have is a strategy group, an umbrella body, a delivery group, a rights agency, an exploratory review, a digital champion and an expert task force. \"This report has been a complete damp squib,\" he said. Industry analysts warned that the report should not end up as a substitute for concrete action - especially where moves to universal broadband were concerned.")

b.train("interesting", "Cybercrime threat rising sharply The threat of cybercrime is rising sharply, experts have warned at the World Economic Forum in Davos. They called for a new system to tackle well-organised gangs of cybercriminals. Online theft costs $1 trillion a year, the number of attacks is rising sharply and too many people do not know how to protect themselves, they said. The internet was vulnerable, they said, but as it was now part of society's central nervous system, attacks could threaten whole economies. The past year had seen \"more vulnerabilities, more cybercrime, more malicious software than ever before\", more than had been seen in the past five years combined, one of the experts reported. But does that really put \"the internet at risk?\", was the topic of session at the annual Davos meeting. On the panel discussing the issue were Mozilla chairwoman Mitchell Baker (makers of the Firefox browser), McAfee chief executive Dave Dewalt, Harvard law professor and leading internet expert Jonathan Zittrain, Andre Kudelski of Kudelski group, which provides digital security solutions, and Tom Ilube, the boss of Garlik, a firm working on online web identity protection. They were also joined by Microsoft's chief research officer, Craig Mundie. To encourage frank debate, Davos rules do not allow the attribution of comments to individual panellists")

b.train("interesting", "Hacker wins court review decision British hacker Gary McKinnon has won permission from the High Court to apply for a judicial review against his extradition to the United States. The 42-year-old from north London, who was diagnosed last August as having Asperger's Syndrome, has admitted hacking into US military computers. His lawyers had said Mr McKinnon was at risk of suicide if he were extradited. Lawyers for the home secretary had argued against the review, saying the risk to Mr McKinnon's health was low. Fresh challenge Lord Justice Maurice Kay and Mr Justice Simon ruled that Mr McKinnon's case \"merits substantive consideration\" and granted him leave to launch a fresh challenge at the court in London. His lawyers had previously told the High Court that if he were removed from his family and sent to the US, his condition was likely to give rise to psychosis or suicide. The condition was not taken into consideration by Home Secretary Jacqui Smith last October when she permitted the extradition. However, her lawyers said she acted within her powers. The judges said that although Ms Smith's decision might be found to be \"unassailable\", Mr McKinnon had an arguable case that should be tested in court.")

b.train("interesting", "Google takes on Apple in mobile On 23 September the US arm of operator T-Mobile is expected to whisk the cloth off the first handset running Google's Android operating system for mobiles. The appearance of the gadget barely 10 months after first unveiling its plans for phones has got many wondering if the search giant will repeat its online success on handsets or if it will suffer a bloody nose. Certainly some industry pundits do not think the initial launch will have much impact. Wait and see \"What we expect will happen is that Google will launch very softly, one device, and the user experience on it will noting to compare to the iPhone,\" said Ilja Laurs, founder of mobile development network GetJar. \"Most likely in the first months the industry will say 'nothing major is here' and it will not have much success at all,\" he added. Geoff Blaber, director of devices and software platforms at consulting firm CCS Insight, added: \"Google has a long way to go.\" He points out that, so far, Google has persuaded few operators to back Android. \"At the moment most operators have taken a 'wait and see' perspective,\" he said. \"Google is going to need the consumers to pull those devices through and build demand.\"")

b.train("interesting", "Microsoft has stepped up the battle to win back users with the latest release of its Internet Explorer browser. The US software giant says IE 8 is faster, easier to use and more secure than its competitors. \"We have made IE 8 the best browser for the way people really do use the web,\" said Microsoft's Amy Barzdukas. \"Microsoft needs to say these things because it continues to lose market share to Firefox, Chrome and Safari,\" said Gartner analyst Neil MacDonald. Recent figures have shown that Microsoft's dominance in this space has been chipped away by competitors. At the end of last year, data from Net Applications showed the software giant's market share dropped below 70% for the first time in eight years to 68%. Meanwhile Mozilla broke the 20% barrier for the first time in its history with 21% of users using its browser Firefox.")

b.train("not_interesting","LONDON (Reuters) - A brain chemical that lifts people out of depression can transform solitary grasshoppers into swarming desert locusts, a finding that could one day help prevent the devastating plagues, researchers said on Thursday. Increases of serotonin, the nerve-signaling chemical targeted by many antidepressants, appears to spark the behavior changes needed to turn the normally harmless insects into bugs that gang up to munch crops, they said. Rogers and colleagues, who published their findings in the journal Science, wanted to find out what triggered the behavior change, which occurs when the insects gather in close quarters.")

b.train("not_interesting","COLOMBO, Sri Lanka (AP) — Sri Lanka's president urged the Tamil Tiger rebels on Friday to allow the estimated 250,000 civilians trapped in the northern war zone to flee to safety following reports of heavy casualties among noncombatants stuck in the shrinking territory. Human rights groups have accused the rebels of holding the civilians hostage and accused the military of launching heavy attacks in areas filled with civilians, including a government-declared \"safe zone\" in the north. A senior U.N. official said both sides appeared to have committed \"grave breaches of human rights.\" The rebels and the military deny the charges. In the appeal published Friday on a government Web site, President Mahinda Rajapaksa said the rebels' refusal to let noncombatants leave was endangering their lives and he accused the rebels — known formally as the Liberation Tigers of Tamil Eelam — of putting their heavy artillery inside the \"safe zone\" and using it as a \"launching pad\" for attacks on government troops.")

b.train("not_interesting", "36 hours in September changed the world. When investment bank Lehman Brothers collapsed, the credit crunch became a global financial crisis. But how bad is that crisis? Was it wrong to let Lehman fail? Or was Lehman just a symptom not the cause of the chaos in the global economy? Tough questions, and the World Economic Forum had lined up five top experts (including two Nobel prize winners) to find answers. The economists among them were Crunch Cassandras; two or three years ago they had predicted that our financial system was headed for a huge liquidity crisis - Nouriel Roubini, Nassim Taleb and economic historian Niall Ferguson. A pity then, a participant said, that two years ago nobody had thought of inviting them to speak at the forum. Little wonder that this session was hugely oversubscribed, with 150 people on the waiting list and probably more than that crowding into one of the cavernous dining rooms that are the hallmark of Davos hotels. Under Davos rules this was a closed session, to encourage frank debate. So with a few exceptions I am not allowed to attribute quotes to individual speakers. But I can report what was said, and this session was an intellectually stimulating eye opener - and utterly depressing (at least economically).")

b.train("not_interesting", "Losing a pet can be devastating, especially when disease claims their lives. The bonds formed between humans and their animal companions (as we've learned from Fable 2) can last a lifetime, if by lifetime you mean about a dozen years or so. One American couple decided that they did not want to say goodbye to their cancer stricken pooch, and instead opted to have an exact clone of their Labrador created in a lab (oh, the irony) immediately after the original puppy passed away. ")

b.train("not_interesting", "US President Barack Obama has telephoned his Chinese counterpart Hu Jintao, the White House says. White House spokesman Robert Gibbs gave no further details, but China's Xinhua news agency said both had \"expressed willingness to further ties\". Mr Hu said China was ready to \"expand co-operation... to confront various global challenges together\", it said. The US and China have not always seen eye to eye on the causes of the current global crisis. Last week, US Treasury Secretary Tim Geithner accused China of \"currency manipulation\" aimed at keeping its export prices low - sustaining its large trade imbalance with the US. Then, in a speech at the economic summit at Davos earlier this week, Chinese Prime Minister Wen Jiabao blamed \"inappropriate macro-economic policies\" for the crisis, in what correspondents say was a swipe at the US.")

b.train("not_interesting", "In times of prosperity, Wall Street executives are highly paid heroes to be emulated. Eye-popping corporate profits and pocket-lining dividends are celebrated like Super Bowl wins and Oscar sweeps. In bad times, like now, the Wall Street Gotbucks find themselves fallen idols on the wrong side of a quick and vicious shift, chastised by President Obama, powerful senators and subpoena-wielding lawmen. Not to mention angry taxpayers who lost savings on Wall Street and who now fund its bailout.")

b.train("not_interesting", "Obama calls recession a disaster President Obama has called the contraction of the US economy in the final quarter of 2008 a \"continuing disaster\" for the US. Speaking at the White House, he also announced a new task force to help middle-class working families. US economic output fell 3.8%, the worst quarterly contraction in more than 26 years, official figures have shown. It is the first time the United States has seen consecutive quarterly declines since 1991. The rate is annualised, which means that if the economy were to shrink at the same rate for a whole year as it did in the final quarter, it would shrink by 3.8%.")

text = " The woman had six other children before the set of eight, which were only the second set of octuplets recorded in the U.S. The babies' grandfather said Friday that his daughter wanted one more child and didn't expect this to happen. Kaiser Permanente's Bellflower Medical Center reports that all is well with the mother and children. Seven babies are breathing unassisted, and one is receiving assisted oxygen through a tube in the nose. Seven are being tube-fed donated breast milk."

text2 = "The online user-generated encyclopaedia Wikipedia is considering a radical change to how it is run. It is proposing a review of the rules, that would see revisions being approved before they were added to the site. The proposal comes after edits of the pages of Senators Robert Byrd and Edward Kennedy gave the false impression both had died. The editing change has proved controversial and sparked a row among the site's editors. Wikipedia's founder, Jimmy Wales, is proposing a system of flagged revisions, which would mean any changes made by a new or unknown user would have to be approved by one of the site's editors, before the changes were published."

text3 = "Man Utd extend their lead at the top of the Premier League as Cristiano Ronaldo's penalty secures a 1-0 win over Everton."

text4 = "Smartphones drive mobile markets There is no doubt that 2008 was the year of the smartphone. The last 12 months has seen the launch of iconic devices such as the iPhone 3G, Google G1, Blackberry Storm and Nokia N97. It also saw the emergence of the electronic ecosystems needed to get the most out of such handsets. But all is not rosy in the smartphone garden. The popularity of these devices has brought to light several problems that look set to become acute in 2009."

text5 = " NEW YORK, Feb 1 (Reuters) - Canadian National Railway (CNR.TO) closed a deal on Saturday to buy the principal lines of Elgin, Joliet & Eastern Railway Co from United States Steel Corp (X.N), the two companies said on Sunday. Canadian National agreed in 2007 to purchase the EJ&E from U.S. Steel as part of a plan to route more freight trains around Chicago, where they face lengthy delays in the congested rail hub."

text6 = " Michael Phelps  may have won a record eight gold medals during the  2008 Summer Olympics in Beijing, but now he’s gaining notoriety for a less lofty achievement after a photo of the swimmer allegedly smoking marijuana from a bong was published in the United Kingdom’s News of the World, the  New York Daily News  reported. Phelps said yesterday he was sorry for his actions, issuing a public apology."

text7 = "Clickable is debuting version 2.0 of its search advertising management suite today, adding to the software a slew of features that should make it easier for small and medium-sized businesses to stay on top of online marketing campaigns held across a variety of advertising networks such as Google, Yahoo and MSN. While it was already possible for Clickable users to import different accounts in order to manage their campaigns from an interface designed to make them more intuitive and effective, Clickable Pro 2.0 now enables them to consolidate management of multiple search advertising campaigns across advertising networks from one central location. To achieve this, Clickable has added features like bulk editing and filtering of keywords which allow agencies and advertisers to rapidly search, edit and export high volumes of keywords across all advertising networks and accounts, as well as a recommendation engine that should allow advertisers to make search campaigns more effective."

pp b.probabilities(text)
puts "text > " + b.classify(text)
puts
pp b.probabilities(text2)
puts "text2 > " + b.classify(text2)

prob2 = b.probabilities(text2)
pp b.probabilities(text2)
puts "text2 > " + b.classify(text2)

puts
pp b.probabilities(text3)
puts "text3 > " + b.classify(text3)
puts
pp b.probabilities(text4)
puts "text4 > " + b.classify(text4)

prob4 = b.probabilities(text4)
pp b.probabilities(text4)
puts "text4 > " + b.classify(text4)


puts
pp b.probabilities(text5)
puts "text5 > " + b.classify(text5)
puts

prob6 = b.probabilities(text6)
pp b.probabilities(text6)
puts "text6 > " + b.classify(text6)

puts
prob7 = b.probabilities(text7)
pp b.probabilities(text7)
puts "text7 > " + b.classify(text7)

puts "text7 > " + b.classify(text7)