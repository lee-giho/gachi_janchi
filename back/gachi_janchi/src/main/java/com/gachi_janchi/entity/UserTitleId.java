package com.gachi_janchi.entity;

import lombok.Data;

import java.io.Serializable;
import java.util.Objects;
@Data

public class UserTitleId implements Serializable {

    private String userId;
    private Long title;

    public UserTitleId() {}

    public UserTitleId(String userId, Long title) {
        this.userId = userId;
        this.title = title;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserTitleId that)) return false;
        return Objects.equals(userId, that.userId) && Objects.equals(title, that.title);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, title);
    }
}
