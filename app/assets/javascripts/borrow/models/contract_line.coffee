window.App.ContractLine.scope = => "/borrow"

window.App.ContractLine.changeTimeRange = (lines, startDate, endDate, inventoryPool)=>
  startDate = moment(startDate).format("YYYY-MM-DD")
  endDate = moment(endDate).format("YYYY-MM-DD")
  for line in lines
    line.start_date = startDate
    line.end_date = endDate
    line.inventory_pool_id = inventoryPool.id
    App.ContractLine.find(line.id).refresh(line)
  $.post "/borrow/contract_lines/change_time_range",
    line_ids: _.map(lines,(l)->l.id)
    start_date: startDate
    end_date: endDate
    inventory_pool_id: inventoryPool.id