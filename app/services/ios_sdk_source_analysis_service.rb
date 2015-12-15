class IosSdkSourceAnalysisService

  class << self
    def find_sdk_similarities(sdk_names = nil)
      sdks = sdk_names.nil? ? IosSdk.select(:id) : IosSdk.where(name: sdk_names)

      if Rails.env.production?
        batch = Sidekiq::Batch.new
        batch.description = "Computing ios sdk source matches" 
        batch.on(:complete, 'IosSdkSourceAnalysisService#on_complete')

        batch.jobs do
          sdks.each do |sdk|
            IosSdkSourceAnalysisWorker.perform_async(sdk.id)
          end
        end
      else
        sdks.sample(1).each do |sdk|
          IosSdkSourceAnalysisWorker.new.perform(sdk.id)
        end
      end
    end

    def write_symmetric_to_file(sdk_ids = nil)
      sdks = sdk_ids.nil? ? IosSdk.select(:id) : IosSdk.where(id: sdk_ids)

      symmetrics = []
      sdks.each_with_index do |sdk, index|
        puts "#{index} out of #{sdks.length}"

        sdk.source_matches.each do |match_sdk|
          symmetrics.push({first: sdk.id, second: match_sdk.id})
        end
      end

      File.open('sym_id_list.txt', 'w') {|f| f.write(symmetrics.map {|pair| "#{pair[:first]}, #{pair[:second]}"}.join("\n"))}
      nil
    end

    def get_edge_tree(edges_file_path)
      d_edges = File.open('sym_id_list.txt') {|f| f.read}
      d_edges = d_edges.split("\n").map {|txt| txt.chomp.split(",").map{|id| id.chomp.to_i}}

      edge_tree = d_edges.reduce({}) do |memo, pair|
        current_value = memo[pair[0]]

        if current_value.present?
          memo[pair[0]].push(pair[1])
        else
          memo[pair[0]] = [pair[1]]
        end

        memo
      end

      edge_tree
    end

    # http://ruby-doc.org/stdlib-2.0.0/libdoc/tsort/rdoc/TSort.html
    def get_strongly_connected_components(edges_file_path)

      # run this in the console beforehand
      # class Hash
      #   include TSort
      #   alias tsort_each_node each_key
      #   def tsort_each_child(node, &block)
      #     fetch(node).each(&block)
      #   end
      # end

      tree = get_edge_tree(edges_file_path)

      # need to hydrate tree with all sdk ids that aren't in tree
      IosSdk.select(:id).each do |sdk|
        next if tree[sdk.id].present?

        tree[sdk.id] = []
      end

      tree.strongly_connected_components
    end

    def review_cycles(edges_file_path: nil, cycles: nil, start_index: 0)

      return "Nothing given" if cycles.nil? && edges_file_path.nil? 

      if cycles.nil?
        cycles = get_strongly_connected_components(edges_file_path).select {|x| x.length > 1}
      end

      cycles[start_index..-1].each_with_index do |cycle_parts, index|
        sdks = IosSdk.where(id: cycle_parts)
        # hydrate the connections for viewing
        map = sdks.reduce({}) do |memo, sdk|
          memo[sdk.name] = {}
          sdk.source_matches.each do |match|
            row = IosSdkSourceMatch.where(source_sdk_id: sdk.id, match_sdk_id: match.id).last
            memo[sdk.name][match.name] = {
              collisions: row.collisions,
              total: row.total,
              ratio: row.ratio
            }
          end
          memo
        end

        ap map


        puts "Reviewing #{index} out of #{cycles.length}"
        puts "Sdks in group:\n#{sdks.map{|x| x.id.to_s + ': ' + x.name}.join("\n")}"
        puts "Continue? [y/n]"
        ans = gets
        return if ans.match(/y/i)
      end
    end

    def inspect_sdk_matches(sdk_id, match_ids = nil, ratio = 0.1)
      IosSdkSourceMatch.where(source_sdk_id: sdk_id, match_sdk_id: match_ids).where("ratio > #{ratio}").reduce({}) do |memo, match_row|
        memo[IosSdk.find(match_row.match_sdk_id).name] = {
          collisions: match_row.collisions,
          total: match_row.total,
          ratio: match_row.ratio
        }
        memo
      end
    end

    def autocreate_groups(start_index: 0)
      groups = File.open('groups.txt') {|f| f.read}.split("\n").reduce([[]]) do |memo, sdk|
        if sdk.blank?
          memo.push([])
        else
          memo.last.push(sdk)
        end
        memo
      end

      leftover = []

      groups[start_index..-1].each_with_index do |group, index|
        puts "Reviewing #{index + start_index} out of #{groups.length}"
        puts "Group"
        puts "----------------------------------"
        puts group.join("\n")
        puts "----------------------------------"
        puts "Create? [y/n]"
        ans = gets
        if ans.match(/y/i)
          puts "Enter the name: "
          name = gets.chomp
          puts "Which is the group leader? [0..#{group.length-1}]"
          index = gets.chomp.to_i

          sdk_id = group[index].split(":").first.chomp.to_i

          group_row = IosSdkSourceGroup.create!(name: name, ios_sdk_id: sdk_id)

          group.each_with_index do |sdk|
            sdk_id = sdk.split(":").first.chomp.to_i
            IosSdk.find(sdk_id).update(ios_sdk_source_group_id: group_row.id)
          end
        else
          leftover.push(group)
        end

        puts "Continue? [y/n]"
        ans = gets
        break if ans.match(/n/i)
      end


      File.open('leftover.txt', 'w') {|f| f.write(leftover.map {|x| x.join("\n")}.join("\n"))}
    end



  end



  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'analyzed_ios_sdk_source')
  end
end