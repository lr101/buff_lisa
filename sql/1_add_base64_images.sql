ALTER TABLE monas ADD base64_image_small varchar(2000) null;
SELECT lo_get(image) FROM monas WHERE image = 44403;