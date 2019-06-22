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
        count = 0
        report = false
        graphs = []
        dashboard = false

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
                #Area Graph test
                area_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.area\"]")
                if area_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    area_graph_test.count.times do
                        graph[:type] = 'Area'
                
                        area_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end

                #river graph tests
                river_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.river\"]")
                if river_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    river_graph_test.count.times do
                        graph[:type] = 'River'
                
                        river_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end

                #Smooth Area
                smooth_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.smoothArea\"]")
                if smooth_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    smooth_graph_test.count.times do
                        graph[:type] = 'Smooth Area'
                
                        smooth_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end

                #Step Graph
                step_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.stepArea\"]")
                if step_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    step_graph_test.count.times do
                        graph[:type] = 'Step'
                
                        step_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end

                #Box Plot graph tests
                box_plot_test = doc.xpath("//*[@class=\"Rave2BundleBoxPlotRenderer large\"]")
                if box_plot_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    box_plot_test.count.times do
                        graph[:type] = 'Box Plot'
                
                        box_plot_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                        count += 1
                    end
                end

                #Bubble Graph
                bubble_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.bubble\"]")
                if bubble_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    bubble_graph_test.count.times do
                        graph[:type] = 'Bubble'
                
                        bubble_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
                            end
                        end
                        arr_y.delete_if { |x| x.empty? }
                        arr_x.delete_if { |x| x.empty? }
                        graph[:y_values] = arr_y
                        graph[:x_values] = arr_x
                        graphs << graph
                    end
                end

                #Hieracrhical Packed Bubbles
                hpbubble_graph_test = doc.xpath("//*[@data-vizbundle=\"com.ibm.vis.hierarchicalPackedBubble\"]")
                if hpbubble_graph_test.count > 0
                    graph = {}
                    arr_x = []
                    arr_y = []
                    hpbubble_graph_test.count.times do
                        graph[:type] = 'Bubble'

                        legend_xml = doc.css('#S_2_legend')
                        graph[:legend] = {}
                        graph[:legend][:min_value] = doc.css('#o_0_startLabel').text
                        graph[:legend][:max_value] = doc.css('#o_0_endLabel').text
                        graph[:legend[:label] = doc.css('.lgd-title').text #may pick up multiple as a class selector
                
                        hpbubble_graph_test.css('text').each do |t|
                            if t.text.include?('0')
                                arr_y << t.text
                            else
                                arr_x << t.text
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

        b.close

        if @info.save
            redirect_to @info
        else
            render :new
        end
    end
end
