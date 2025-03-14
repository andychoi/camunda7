package com.example.workflow.service;

import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.nio.file.Files;

@Service
public class ProcessDeploymentService implements CommandLineRunner {

    private final ResourceLoader resourceLoader;
    private final RestTemplate restTemplate = new RestTemplate();

    public ProcessDeploymentService(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @Override
    public void run(String... args) throws IOException {
        deployBpmn("processes/simple-process.bpmn");
    }

    private void deployBpmn(String bpmnPath) throws IOException {
        Resource resource = resourceLoader.getResource("classpath:" + bpmnPath);
        byte[] bpmnBytes = Files.readAllBytes(resource.getFile().toPath());

        String camundaUrl = "http://camunda-platform:8080/engine-rest/deployment/create";

        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Content-Type", "multipart/form-data");

        org.springframework.http.HttpEntity<byte[]> entity = new org.springframework.http.HttpEntity<>(bpmnBytes, headers);

        restTemplate.postForObject(camundaUrl, entity, String.class);
        System.out.println("✅ BPMN deployed: " + bpmnPath);
    }
}