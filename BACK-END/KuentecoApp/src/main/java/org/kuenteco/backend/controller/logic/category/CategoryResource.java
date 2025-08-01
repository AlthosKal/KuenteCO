package org.kuenteco.backend.controller.logic.category;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.kuenteco.backend.dto.logic.category.CategoryDTO;
import org.kuenteco.backend.dto.logic.category.NewCategoryDTO;
import org.kuenteco.backend.exception.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Category", description = "API para la gestión de categorías")
public interface CategoryResource {

    @Operation(
            summary = "Obtener todas las categorías",
            description = "Recupera una lista de todas las categorías",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Lista de categorías",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = CategoryDTO.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "[ { \"id\": 1, \"name\": \"Alimentación\" } ]")))
            })
    @GetMapping
    ResponseEntity<?> getCategories(
            HttpServletRequest request,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(required = false) String kind);

    @Operation(
            summary = "Agregar nueva categoría",
            description = "Crea una nueva categoría en el sistema",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "201",
                        description = "Categoría creada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Categoría creada correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema =
                                                    @Schema(
                                                            implementation =
                                                                    NewCategoryDTO.class))))
    @PostMapping("/add")
    ResponseEntity<?> addCategory(
            @Valid @RequestBody NewCategoryDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Actualizar categoría",
            description = "Actualiza una categoría existente",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "200",
                        description = "Categoría actualizada",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ApiResponse.class),
                                        examples =
                                                @ExampleObject(
                                                        value =
                                                                "{ \"message\": \"Categoría actualizada correctamente\" }")))
            },
            requestBody =
                    @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            content =
                                    @Content(
                                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                                            schema = @Schema(implementation = CategoryDTO.class))))
    @PatchMapping("/update")
    ResponseEntity<?> updateCategory(
            @Valid @RequestBody CategoryDTO dto, HttpServletRequest request);

    @Operation(
            summary = "Eliminar categoría",
            description = "Elimina una categoría por su ID",
            responses = {
                @io.swagger.v3.oas.annotations.responses.ApiResponse(
                        responseCode = "204",
                        description = "Categoría eliminada")
            },
            parameters = {
                @Parameter(
                        in = ParameterIn.PATH,
                        name = "id",
                        description = "ID de la categoría a eliminar",
                        required = true)
            })
    @DeleteMapping("/{id}")
    ResponseEntity<?> deleteCategory(@PathVariable Integer id, HttpServletRequest request);
}
