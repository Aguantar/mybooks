package model.view;

import lombok.Data;

@Data
public class OrderItemView {
    private Long orderItemId;
    private Long orderId;
    private Long bookId;
    private int  quantity;
    private int  unitPrice;

    // joined from books
    private String bookTitle;
    private String coverImage;
}
