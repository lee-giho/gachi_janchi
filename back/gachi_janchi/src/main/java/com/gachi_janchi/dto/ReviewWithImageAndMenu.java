package com.gachi_janchi.dto;

import java.util.List;

import com.gachi_janchi.entity.Review;
import com.gachi_janchi.entity.ReviewImage;
import com.gachi_janchi.entity.ReviewMenu;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewWithImageAndMenu {
  Review review;
  List<ReviewImage> reviewImages;
  List<ReviewMenu> reviewMenus;
}
