class IbmInfosController < ApplicationController
    def index
        @infos = IbmInfo.all
    end

    def show
        @info = IbmInfo.find(params[:id])
    end

    def new
        @info = IbmInfo.new
    end
    
    def create
        @info = IbmInfo.new
        @info.IBMid = params[:ibm_info][:IBMid]
        @info.password = params[:ibm_info][:password]
        @info.report_name = params[:ibm_info][:report_name]

        p @info

        b = Watir::Browser.new(:chrome)
        ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'
        b.goto(ibm_login_url)

        b.text_field(name: 'ibmid').set @info.IBMid
        b.button(type: 'submit').click
        b.text_field(name: 'password').set @info.password
        b.button(type: 'submit').click

        sleep 5
        b.button(type: 'submit').click
        sleep 5

        b.div(title: '‪sample product report‬').click
        sleep 20
        r_html = b.html
        @info.report_xml = Nokogiri::HTML.parse(r_html)
        b.close

        if @info.save
            redirect_to @info
        else
            render :new
        end
    end
end
