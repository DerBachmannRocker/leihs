# When "he checks his basket" do
#   # access a method, that is being called by the EJS frontend code to
#   # update the OrderLine availabilites
#   get "order.ext_json"
#   @order = @user.orders.first # TODO: .first => not nice
# end

# When "$who deletes the first line" do | who|
#   # TODO: we should be passing through the controller/view here
#   @order.remove_line(@order.order_lines.first)
# end

# Then "the availability of all $document_type reservations should be cached" do |document_type|
#   case document_type
#     when "order";    @document = @order
#     when "contract"; @document = @contract
#   end
#   # we *must* reload here - thus the "true" - otherwise Rails will cache
#   # the old order_lines values and muss the fact that one of them has been
#   # updated. See Rails docu -> Associations -> Caching
# #tmp#8#old-availability#
# #  @document.reservations.reload.each do |l|
# #    l.cached_available.should_not == nil
# #  end
# end

#tmp#8#old-availability#
# Then "the availability of the respective orderline should be cached" do
#   # uh, dirty...
#   step "the availability of all order reservations should be cached"
# end

# #tmp#8#old-availability#
# Then "the availability cache of $quantifier $document_type reservations should have been invalid$ated" do |quantifier,document_type,ated|
#   case document_type
#     when "order";    @document = @order
#     when "contract"; @document = @contract
#   end
# #tmp#8#old-availability#
# #  @document.reservations.reload.each do |l|
# #    l.cached_available.should == nil
# #  end
# end

