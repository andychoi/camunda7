package com.example.workflow.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;

@RestController
public class FormController {

    @GetMapping(value = "/forms/simple-form.html", produces = MediaType.TEXT_HTML_VALUE)
    public String getSimpleForm() throws IOException {
        ClassPathResource resource = new ClassPathResource("static/forms/simple-form.html");
        return new String(Files.readAllBytes(resource.getFile().toPath()));
    }
}