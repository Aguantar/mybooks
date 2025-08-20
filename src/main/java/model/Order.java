package model;

import lombok.Data;

@Data
public class Order {
    private Long orderId;
    private Long userId;
    private String status;       // PENDING/PAID/...
    private Integer totalAmount; // 원단위
    private String address;
    private String postcode;
    private String courier;
    private String trackingNo;
    private java.util.Date shippedAt;
    private java.util.Date deliveredAt;



}
