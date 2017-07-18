class Status < ActiveHash::Base
  self.data = [
    {:id => 1, :name => "未対応"},
    {:id => 2, :name => "アポ獲得"},
    {:id => 3, :name => "資料送付"},
    {:id => 4, :name => "新規営業お断り"},
    {:id => 5, :name => "不在"}
  ]
end
