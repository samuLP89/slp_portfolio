
# Funciones que se utilizan para la salida de los resultados 



grafico_metricas <- function(modelo){
  
  g1<- plot(modelo, main="Métrica ROC") 
  
  g2<- plot(modelo, metric="Accuracy", main="Métrica Accuracy")
  g3<- plot(modelo, metric="Kappa", main="Métrica Kappa")
  
  print(g1)
  grid.arrange(g2, g3, ncol=2)
  
}


# Resultados 


resultados <-function(modelo, texto){
  resultados <- modelo$results %>% arrange(desc(ROC))
  head(resultados, 12)%>% 
    knitr::kable("html",  caption =paste("RESULTADOS DEL MODELO", texto))%>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover"),
                              full_width = F, font_size = 14)
}



# Mejor modelo


mejor_modelo <-function(modelo){ 
  print("El mejor módelo es el que muestra los siguientes hiperparámetros:")
  
  modelo$bestTune%>%
    knitr::kable("html")%>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover"),
                              full_width = F, font_size = 12)
  
  
}

# Curva ROC

curvas_ROC<- function(modelo, texto, train, test){
  
  # Establezco el segundo nivel(si responde a la oferta), como referencia
  clase <- modelo$levels[2]
  
  # Valores predichos y ROC para entrenamiento y validación
  pred_train <- predict(modelo, train , type="prob")
  curvaROC_train <- roc(train[ , c(length(train))],
                        pred_train[,clase])
  
  pred_test <- predict(modelo, test, type="prob")
  curvaROC_test <- roc(test[ , c(length(test))],pred_test[,clase])
  
  # Salidas
  
  plot(curvaROC_test,axes=TRUE, col="blue",
       auc.polygon=TRUE,grid.col=c("red", "aliceblue"),
       max.auc.polygon=TRUE, grid=c(0.1, 0.2), 
       main=paste("Curvas ROC del modelo",texto),
       print.auc=TRUE, auc.polygon.col="aquamarine1")
  plot(curvaROC_train, col="red", add=TRUE)
  legend("bottomright", legend = c("Test", "Validación"), col = c("blue", "red"), lwd = 2)
  
  
  print(paste(c("ROC del modelo con el fichero de test:"), auc(curvaROC_test)))
  
} 



# Importancia de las variables

importancia_var<-function(modelo, texto){
  
  
  VarImp <-varImp(modelo)
  
  ggplot(VarImp)+
    geom_bar(stat = "identity", color="#E6B0F0") +
    geom_text(aes(label=round(Importance,2)), hjust=1.2, color="white", size=2) +
    labs(title="Importancia de las variables", 
         subtitle = paste("Modelo", texto), x="Variables", y="Importancia")
  
}



# Validación - Predicción

validation <- function(modelo, texto, train, test){
  pred_train  <- predict(modelo, train, type="raw") 
  pred_test  <- predict(modelo, test, type="raw")
  
  print(paste("Modelo", texto, "- Tabla de confusion para los datos de entrenamiento"))
  print(confusionMatrix(data = pred_train, reference = train$y))
  
  print(paste("Modelo", texto, "- Tabla de confusion para los datos de validción"))
  confusionMatrix(data = pred_test, reference = test$y)
} 


# Resumen del modelo, Mostrando datos del entrenamiento y de la validacion

resumen <-  function(modelo,train, test){
  
  clase <- modelo$levels[2]
  
  # Entrenamiento
  
  pred_train_prob <- predict(modelo, train, type="prob")
  curvaROC_train <- roc(train[ , c(length(train))],pred_train_prob[,clase])
  AUC_train <- round(auc(curvaROC_train),digits=3)
  
  pred_train <- predict(modelo, train, type="raw")
  confusion_train <- confusionMatrix(data = pred_train, reference = train$y)
  Accuracy_train=round(c(confusion_train[["overall"]][["Accuracy"]]), digits=3)
  AciertosClSI_train=round(c(confusion_train[["byClass"]][["Pos Pred Value"]]),
                           digits=3)
  AciertosClNO_train=round(c(confusion_train [["byClass"]][["Neg Pred Value"]]),
                           digits=3)
  Kappa_train=round(c(confusion_train[["overall"]][["Kappa"]]), digits=3)
  Sensitivity_train=round(c(confusion_train[["byClass"]][["Sensitivity"]]),
                          digits=3)
  Specificity_train=round(c(confusion_train[["byClass"]][["Specificity"]]),
                          digits=3)
  
  train <- c(AUC_train, Accuracy_train, AciertosClSI_train, AciertosClNO_train,
             Kappa_train, Sensitivity_train, Specificity_train)  
  
  # Validación
  pred_test_prob <- predict(modelo, test, type="prob")
  curvaROC_test <- roc(test[ , c(length(test))],pred_test_prob[,clase])
  AUC_test <- round(auc(curvaROC_test), digits=3)
  
  pred_test <- predict(modelo, test, type="raw")
  confusion_test <- confusionMatrix(data = pred_test, reference = test$y)
  Accuracy_test=round(c(confusion_test[["overall"]][["Accuracy"]]), digits=3)
  AciertosClSI_test=round(c(confusion_test[["byClass"]][["Pos Pred Value"]]),
                          digits=3)
  AciertosClNO_test=round(c(confusion_test [["byClass"]][["Neg Pred Value"]]),
                          digits=3)
  Kappa_test=round(c(confusion_test[["overall"]][["Kappa"]]), digits=3)
  Sensitivity_test=round(c(confusion_test[["byClass"]][["Sensitivity"]]),
                         digits=3)
  Specificity_test=round(c(confusion_test[["byClass"]][["Specificity"]]),
                         digits=3)
  
  test <- c(AUC_test, Accuracy_test, AciertosClSI_test, AciertosClNO_test,
            Kappa_test, Sensitivity_test, Specificity_test)  
  
  resumen <- rbind(train,test)
  colnames(resumen) <- c("AUC", "Accuracy", "Aciertos Clase SI",
                         "Aciertos Clase NO","Kappa", "Sensitivity",
                         "Specificity")
  rownames(resumen) <- c("Datos Entrenamiento", "Datos Validación")
  resumen
}


