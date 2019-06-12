ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'

b.text_field(name: 'ibmid').set "dhirst@uwo.ca"
b.button(type: 'submit').click
b.text_field(name: 'password').set "Fraggen8779!"
b.button(type: 'submit').click

if b.url == "https://www.ibm.com/account/reg/us-en/subscribe?formid=urx-34710"
    b.button(type: 'submit').click
end

b.div(title: '‪sample product report‬').click
r_html = b.html
report_xml = Nokogiri::HTML.parse(r_html)