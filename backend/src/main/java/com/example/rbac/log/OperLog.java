package com.example.rbac.log;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface OperLog {

    /** 模块名称 */
    String title();

    /** INSERT / UPDATE / DELETE / EXPORT / OTHER */
    String businessType() default "OTHER";
}
