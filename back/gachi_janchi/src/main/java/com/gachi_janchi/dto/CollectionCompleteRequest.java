package com.gachi_janchi.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CollectionCompleteRequest {
    private String collectionName; // 사용자가 완성하려는 컬렉션 이름
}
