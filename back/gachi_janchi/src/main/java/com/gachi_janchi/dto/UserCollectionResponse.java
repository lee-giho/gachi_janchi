package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UserCollectionResponse {
    private String collectionName;
    private String acquiredAt;
}
