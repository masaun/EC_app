class CombineItemInCart < ActiveRecord::Migration
  def change
    # カート内に1つの商品に対して複数の商品があった場合、1つの品目に置き換える。
    Cart.all.each do |cart|
      # カート内の各商品の数をカウントする。
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums = each do |product_id, quantity|
        if quantity > 1
          # 個別の項目を削除する
          cart.line_items.where(product_id: product_id).delete_all
          
          # 1つの品目に置き換える
          cart.line_items.create(product_id: product_id, quantity: quantity)
        end
      end
    end
  end

  def down
    # 「数量 > 1」の品目を複数の項目に分割する
    LineItems.where("quantity > 1").each do |line_item|
      # 個別の品目を追加する
      line_item.quantity.times do
        LineItem.create cart_id: line_item.cart_id,
          product_id: line_item.product_id, quantity: 1
      end

      # 元の品目を削除する
      line_item.destroy
    end
  end

end
