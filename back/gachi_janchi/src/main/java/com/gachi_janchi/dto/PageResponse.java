package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class PageResponse<T> {
  private List<T> content;
  private int totalPages;
  private long totalElements;
  private int pageNumber;
  private int pageSize;
}
