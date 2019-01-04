#######################

###### R code for Chem1210 exam grading ######

###### version 0.6.6f - all forms until report output + rearranged output
######               - consider multiple answers     for e-final
######               - consider multiple keys        for e-final  
######               - output tokenized answers     for e-final 

#######################


### function 'rbind.fill' needs package 'plyr'
# install.packages("plyr")
library(plyr)



###### 1. Clean and save scantron file

### Does the file have version number?
### If not, ask students bubble version number

##### 1.1 combine all 5 versions

### fill 'Version' column with corresponding letters
### SSN without any answers is not included

##### 1.2 save as # Chem1210fa15ef.csv #



###### 2. set directory as the one containing organized scantron file

# if no multiple answers
setwd(".../fa15/gradeExam/efmono")

# if multiple answers
# setwd(".../fa15/gradeExam/e2multi2")


###### 3. Read organized scantron file, transfer to tokens

##### 3.1 read organized file

Chem1210fa15ef.df <- read.csv("Chem1210fa15ef.csv", fill=TRUE)

### check the file

head(Chem1210fa15ef.df)
dim(Chem1210fa15ef.df)
# [1] 46   5

totalStu <- nrow(Chem1210fa15ef.df)


##### 3.2 split answers (return a list)

answers_sep.list <- strsplit(as.character(Chem1210fa15ef.df$Answers), "")

# head(answers_sep.list)


##### 3.3 tokenize splitted answers

answers_sep.df <- lapply(answers_sep.list, function(x) as.data.frame(t(x)))

head(answers_sep.df)
dim(answers_sep.df)
# NULL (list)

# now bind to one data frame
answers_token.df <- rbind.fill(answers_sep.df)
dim(answers_token.df)
# [1] 46  50


##### 3.4 organize tokenized answer file
### column names of questions
Questions = c("Q1","Q2","Q3","Q4","Q5","Q6","Q7","Q8","Q9","Q10","Q11","Q12","Q13",
              "Q14","Q15","Q16","Q17","Q18","Q19","Q20","Q21","Q22","Q23","Q24","Q25",
              "Q26","Q27","Q28","Q29","Q30","Q31","Q32","Q33","Q34","Q35","Q36","Q37",
              "Q38","Q39","Q40","Q41","Q42","Q43","Q44","Q45","Q46","Q47","Q48","Q49","Q50" )

# change column names
colnames(answers_token.df) <- Questions

# combine with student information
Chem1210fa15ef_answers_token.df <- cbind(Chem1210fa15ef.df[, 1:4], answers_token.df)

tail(Chem1210fa15ef_answers_token.df)
dim(Chem1210fa15ef_answers_token.df)
# [1] 46  54


###########################################################
###### 4. separate versions

forms <- list("A", "B", "C", "D", "E")

# read different forms to different df, and then store in a list

Chem1210fa15e2_token.list <- lapply(forms, function(x){
                                 Chem1210fa15e2_answers_token.df[which(Chem1210fa15e2_answers_token.df[,5]==x), ]
                              })


# check
head(Chem1210fa15e2_token.list[[1]], 3)
dim(Chem1210fa15e2_token.list[[1]])
# [1] x 30  

head(Chem1210fa15e2_token.list[[3]], 3)


### csv files

token_file_name <- sprintf("student_answer_token_form%s.csv", LETTERS[1:5])

# write report file 
lapply(1:5, function(n){
          write.csv(Chem1210fa15e2_token.list[[n]], token_file_name[n])
      })




###### 5. Percent of choices selected in each of the 25 questions


# number of students in each version 

numStu.list <- lapply(Chem1210fa15e2_token.list, function(x) nrow(x))

numStu.list

numStu.vec <- unlist(numStu.list)
########################################################

##### 5.1. choice 'A', "B", "C", "D", "E" 
### get vectors of number of choices "A", "B", "C", "D", "E" in each question of each form

choices <- list("A", "B", "C", "D", "E")

numChoices.df <- sapply(choices, function(c){
                        apply(Chem1210fa15ef_answers_token.df[, 5:54], 2, function(x) sum(x==c))
                 })
                         
  
numChoices.df


### get vector of percent of choice 'A' in each question

# percentChoices.df <- numChoices.df

percentChoices.df <- round(100 * numChoices.df / totalStu, 1)

colnames(percentChoices.df) = c("percentA", "percentB", "percentC", "percentD", "percentE")


percentChoices.df



###### 6. Read answer keys - only read one of 6.1 or 6.2!

##### 6.1 read key.csv when only single answer is used! #####

Chem1210fa15efkey.df <- read.csv("Chem1210fa15efkey.csv")


##### 6.2 read keys.csv when multiple answer is used! #####

# Chem1210fa15e2keys.df <- read.csv("Chem1210fa15e2keys.csv")

# check
Chem1210fa15efkey.df


# number of questions

nq <- ncol(Chem1210fa15efkey.df) - 1
nq
# [1] 50



###### 7. Grading 

# answer token without student info

Chem1210fa15ef_result.df <- Chem1210fa15ef_answers_token.df[, 5:54]

Chem1210fa15ef_result.df

##### 7.1 Compare answers to key - form A


##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

##### Start single answer step! ##### 
##### if keys is NOT available! ##### 
##### if keys is available, skip this step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

### lapply - for each df in the list
### apply - for each row; mapply - for each value in a row
### it returns 25 rows (Questions) x num_stu in a specific form columns. So use transform
 

Chem1210fa15ef_result.df <- t(apply(Chem1210fa15ef_result.df, 1, function(result){
                               mapply(function(ans, key){
               if(ans==key){
                  ans=1
               } else{
                 ans=0
               }
             },
            ans=result, key=Chem1210fa15efkey.df[1, 2:(nq+1)]
           )
        }
      )
     )
  
Chem1210fa15ef_result.df

##### end of single answer step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 




##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

##### Start multiple answer step! ##### 
##### ONLY if keys is available! ##### 
##### otherwise skip this step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

##### Read multiple answer keys

Chem1210fa15e2_result.list <- lapply(1:5, function(n){
                 t(apply(Chem1210fa15e2_result.list[[n]], 1, function(result){
                               mapply(function(ans, key1, key2){
               if(ans==key1 | ans==key2){
                  ans=1
               } else{
                 ans=0
               }
             },
            ans=result,key1=Chem1210fa15e2keys.df[n, 2:(nq+1)],key2=Chem1210fa15e2keys.df[n+5, 2:(nq+1)]
           )
        }
      )
     )
   })


##### end of multiple answer step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 



##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

##### Start assign 1 point to a question anyway step! ##### 
##### ONLY if mkey is available! ##### 
##### otherwise skip this step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 

##### Read multiple answer keys

mkey.df <- read.csv("Chem1210fa15e2mkey.csv")


# for (i in ncol(mkey.df)){

for (i in seq_along(mkey.df)){
  Chem1210fa15e2_result.list[[i]][,  mkey.df[,i]] = 1 
}

##### end of assign 1 point to a question anyway step! ##### 

##### ##### ##### ##### ##### ##### ##### ##### ##### ##### 



##### 7.2 grade sum

### total grade of each student in the 'Grade' list


Grade.vec <- rowSums(Chem1210fa15ef_result.df)

Grade.vec

### desriptional

average <- round(mean(Grade.vec))

average

min <- min(Grade.vec)
max <- max(Grade.vec)


##### 7.3 combine student info, individual grade and sum grade


grades.df <- cbind(Chem1210fa15ef_answers_token.df[,1:4], Grade.vec, Chem1210fa15ef_result.df)
                     
grades.df

##### 7.4 output grade files #####

write.csv(grades.df, "Chem1210finalGrades.csv")
      


##### 7.5 sort by grade

grades_sort.df <- grades.df[order(-grades.df[,5]), ]


##### 7.6 output sorted grade files #####

grade_sort_file_name <- sprintf("grade_sort_form%s.csv", LETTERS[1:5])

# write sorted grades file - 1 and 0

write.csv(grades_sort.df, "Chem1210finalGrades_sort.csv")



###### 8. Difficulty and Discrimination

##### 8.1 Difficulty  


Difficulty.vec <- round(colSums(Chem1210fa15ef_result.df) / totalStu, 3)
                         
Difficulty.vec 

##### 8.2 Difficulty  - 27%

# get number of 27%

numStu27 <- round(totalStu * 0.27)
numStu27

# highest 27% in the sorted grade

Difficulty_h27.vec <- round(colSums(grades_sort.df[1:numStu27, -(1:5)]) / numStu27, 3)
                             
Difficulty_h27.vec

# lowest 27% in the sorted grade

Difficulty_l27.vec <- round(colSums(grades_sort.df[(1+totalStu-numStu27):totalStu, -(1:5)]) / numStu27, 3)
                             
Difficulty_l27.vec

# Discrimination - difference between high and low 27%

Discrimination.vec <- Difficulty_h27.vec - Difficulty_l27.vec
                            
Discrimination.vec

# combine these four

Difficulty_cbind.df <- cbind(Difficulty.vec, Difficulty_h27.vec, Difficulty_l27.vec, Discrimination.vec)
                           

Difficulty_cbind.df


###### 9. Generate report 

##### 9.1 create report

report.df <- cbind(Questions, t(Chem1210fa15efkey.df[1,2:(nq+1)]), percentChoices.df, Difficulty_cbind.df)

report.df


# change colnames

report_names <- c("Question", "key", "perA", "perB", "perC", "perD", "perE", "diff", "diff_h27", "diff_l27", "disc")

colnames(report.df) <- report_names

report.df


##### 9.2 output report files #####

### csv files

report_file_name <- sprintf("report_form%s.csv", LETTERS[1:5])

# write report file 
write.csv(report.df, "Chem1210finalGrades_report.csv")