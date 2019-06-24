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
        page_names = []
        legend_count = 0
        report = false
        graphs = []
        dashboard = false
        sum_of_all_graphs = 0
        graph_types = ['hierarchicalPackedBubble', 'area', 'river','smoothArea', 'stepArea', 'heatmap', 'bubble', 'line', 'smoothLine', 'tiledmap', 'marimekko', 'network', 
        'pie', 'radar', 'treemap', 'waterfall', 'wordcloud', 'dial', 'simpleCombination']
        graphs_with_legends = ['hierarchicalPackedBubble', 'heatmap', 'bubble']
    
        b = Watir::Browser.new(:chrome)
        ibm_login_url = 'https://www.ibm.com/account/reg/us-en/login?formid=urx-34710'
        b.goto(ibm_login_url)

        b.text_field(name: 'ibmid').set @info.IBMid
        b.button(type: 'submit').click
        b.text_field(name: 'password').set @info.password
        b.button(type: 'submit').click

        b.wait
        b.button(type: 'submit').click
        b.wait

        #Go to the report
        b.button(title: 'My content').click
        b.wait
        b.div(title: @info.report_name).click
        b.wait
        
        #Check to see if the report is actually a dashboard
        if b.url.include?('dashboard')
            dashboard = true
        else
            report = true
        end

        #Switch to the correct iframe where the report document is housed
        if b.iframe(id: 'rsIFrameManager_1').exists? && dashboard == false
            b.driver.switch_to.frame('rsIFrameManager_1')
        elsif b.iframe.exists? && dashboard == false
            b.driver.switch_to.frame(1)
        end

        #get a basic nokogiri XML document to use for checks and to store later
        doc = Nokogiri::HTML.parse(b.html)

        if report == true
            graph_types.each do |g|
                graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.#{g}\"]")
                if graph_test.count > 0
                    sum_of_all_graphs += graph_test.count
                    graph = {}
                    arr_x = []
                    arr_y = []
                    graph_test.each do |t|
                        graph[:type] = g

                        legend_xml_all = doc.css('#S_2_legend')
                        legend_xml = legend_xml_all[legend_count]
                        legend = {}

                        graphs_with_legends.each do |x| 
                            if graph[:type] == x
                                1.times do
                                    legend[:min_value] = legend_xml.css('#o_0_startLabel').text
                                    legend[:max_value] = legend_xml.css('#o_0_endLabel').text
                                    legend[:label] = legend_xml.css('.lgd-title').text
                                    legend_count += 1
                                end
                            end
                        end

                        graph[:legend] = legend

                        t.css('text').each do |i|
                            if i.text.include?('0')
                                arr_y << i.text
                            else
                                arr_x << i.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end
            end
        end

        b.close

        if @info.save
            redirect_to @info
        else
            render :new
        end
    end
end
