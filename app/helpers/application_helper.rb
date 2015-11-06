module ApplicationHelper
 
  # Methods in this file are normally only available to views.
  
  #===========================
  #         for VIEWS
  #===========================
  def gravatar_for(chef, options = { size: 80} )
    gravatar_id = Digest::MD5::hexdigest(chef.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    return image_tag(gravatar_url, alt: chef.name, class: "gravatar")
  end
  
  def paginationInfo(list, items_per_page, urlParams)
    list_size = list.size
    if urlParams.has_key?(:page) && urlParams[:page].to_i > 1
      begin_item_num = ((urlParams[:page].to_i-1) * items_per_page) + 1
    else
      begin_item_num = 1
    end
    end_item_num = begin_item_num + (items_per_page-1)
    end_item_num = (end_item_num > list_size)? list_size : end_item_num
  
    return { :begin => begin_item_num.to_s, :end => end_item_num.to_s, :per_page => items_per_page.to_s, :list_size => list_size.to_s }
  end
 
  # how many up or down votes have a chef's recipes received.
  def chef_recipes_likes(chef, type)
    options = { obj_chef: chef, b_thumbs_up_total: type == "up", b_thumbs_down_total: type =="down", b_forRecipes: true }
    totals = model_likes(options)[3]
    return (type == "up") ? totals[:thumbs_up_total]: totals[:thumbs_down_total]
    
  end
   
end
