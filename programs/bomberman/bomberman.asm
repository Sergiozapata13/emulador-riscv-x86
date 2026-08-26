
# Here I define the constants that will be used along the code
.eqv TOTAL_PIXELS, 8192 # The total ammount of pixels in the screen
.eqv FOUR_BYTES, 4 # The displacement in memory is done words which equals four bytes

.eqv TITLE_SCREEN_FIRST_LINE_ROW_Y, 0
.eqv TITLE_SCREEN_SECOND_LINE_ROW_Y, 12

.eqv PONG_TEXT_X, 21
.eqv PONG_TEXT_Y, 5
.eqv PONG_TEXT_H, 5

.eqv PRESS_TEXT_X, 9
.eqv PRESS_TEXT_Y, 15
.eqv PRESS_TEXT_H, 4

.eqv NAME_TEXT_X 4
.eqv NAME_TEXT_Y 24
.eqv NAME_TEXT_H, 4

.eqv KEY_INPUT_ADDRESS 0xFFFF0004
.eqv KEY_STATUS_ADDRESS 0xFFFF0000
# For reference of those addreses check https://urldefense.com/v3/__https://www.it.uu.se/education/course/homepage/os/vt18/module-1/memory-mapped-io/__;!!O7R4XxaP!ePrGUOYpXd3_uNr3xPOrsqdR13pco8EzYufjVPFN0MfgL6-CEHrfTUMIF-bzNMx0aQQBd3XIDkdsQGUtRgEY3MA2VnSxXiJx$ 

.eqv ASCII_1 0x00000031
.eqv ASCII_2 0x00000032

.eqv MOV_STAY 0
.eqv MOV_UP 1
.eqv MOV_DOWN 2
.eqv MOV_RIGHT 3
.eqv MOV_LEFT 4

.eqv PLAYER_X_START 13
.eqv PLAYER_Y_START 13

.eqv INITIAL_BALL_X_POS 32
.eqv INITIAL_BALL_Y_POS 0

.eqv SCORE_FIRST_ROW_POINTS 5
.eqv SCORE_SECOND_ROW_POINTS 6
.eqv ROW_1 1
.eqv ROW_3 3
.eqv P1_SCORE_COLUMN 1
.eqv P2_SCORE_COLUMN 54
.eqv GAME_WIN_POINTS 10

.eqv PADDLE_LENGTH 0

.eqv TOP_PADDLE_Y_ROW 0
.eqv BOTTOM_PADDLE_Y_ROW 31 #  31 - 5 = 26 Thats the lowest point that paddle y can reach

.eqv PLAYER_1_PADDLE_X_POS 13
.eqv PLAYER_2_PADDLE_X_POS 50
.eqv BALL_Y_VELOCITY_REDUCTION -1

.eqv LEFT_COLLISION_X_POS 14
.eqv RIGHT_COLLISION_X_POS 49
# The constants for the ball-pallet collision position
.eqv TOP_HIGH 0
.eqv TOP_MID 1
.eqv TOP_LOW 2
.eqv BOTTOM_HIGH 3
.eqv BOTTOM_MID 4
.eqv BOTTOM_LOW 5
# The horizontal wall limists
.eqv Y_DOWN_LIMIT 31
.eqv Y_UP_LIMIT 0
.eqv Y_MAX_COLLISION_VELOCITY 1
# Player modes
.eqv ONE_PLAYER_MODE 1
.eqv TWO_PLAYER_MODE 2
# ASSCII characters
.eqv ASCII_W 119
.eqv ASCII_S 115
.eqv ASCII_D 100
.eqv ASCII_A 97
.eqv ASCII_SPACE 32 
.eqv ASCII_O 111
.eqv ASCII_L 108
# The coordinmates of the end game screen
.eqv P_CHAR_WIN_X 26
.eqv P_CHAR_WIN_Y 5
.eqv P_CHAR_WIN_H 5

.eqv PLAYER_NUM_WIN_X 33
.eqv PLAYER_NUM_WIN_Y 5
.eqv PLAYER_NUM_WIN_H 5

.eqv WINS_TEXT_X, 21
.eqv WINS_TEXT_Y, 16
.eqv WINS_TEXT_H, 5
# The coordinmates of the end game screen
.eqv P_CHAR_WIN_X 26
.eqv P_CHAR_WIN_Y 5
.eqv P_CHAR_WIN_H 5

.eqv PLAYER_NUM_WIN_X 33
.eqv PLAYER_NUM_WIN_Y 5
.eqv PLAYER_NUM_WIN_H 5

.eqv WINS_TEXT_X, 21
.eqv WINS_TEXT_Y, 16
.eqv WINS_TEXT_H, 5

.eqv NO_COLLISION 0
.eqv COLLISION 1

.eqv MAP_1_X 9
.eqv MAP_1_Y 6

.eqv BOMB_ATTEMPT_X, 3
.eqv BOMB_ATTEMPT_Y, 10 
.eqv TIME_SEG, 30

.eqv SCORE_FIRST_ROW_POINTS 5
.eqv SCORE_SECOND_ROW_POINTS 6
.eqv ROW_1 1
.eqv ROW_3 3
.eqv P1_SCORE_COLUMN 1
.eqv P2_SCORE_COLUMN 54
.eqv GAME_WIN_POINTS 10

.eqv ENEMY1_X1 24
.eqv ENEMY1_Y1 3

.eqv ENEMY1_X2 36
.eqv ENEMY1_Y2 3

.eqv ENEMY1_X3 42
.eqv ENEMY1_Y3 3

.eqv PLAYER_X1 18
.eqv PLAYER_Y1 3

.eqv PLAYER_X2 6
.eqv PLAYER_Y2 14

.eqv PLAYER_X3 6
.eqv PLAYER_Y3 27

.eqv P1_SCORE_COLUMN 1

 # Begin of the data section
.data
	color_white:	.word 0x00ffffff
	color_black:	.word 0x00000000
	color_red:	.word 0x00ff0000
	color_cyan: 	.word 0x0000ffff
	color_orange:	.word 0x00ffa500
	color_green:    .word 0x00008000
	color_silver:   .word 0x00E0E0E0
	color_yellow:   .word 0x00FFFF00
	color_yellow2:  .word 0x00FFFF80
	color_purple:   .word 0x00643B9F
	
	player_mode:	.word 0
	agent:          .word 0x00000000
	# For identifies which element (player or enemy) the function is handling
		# 0 is the player
		# 1 is the enemy 2
		# 2 is the enemy 2
	
	ball_y_speed:	.word -1	# The wait steps before moving in the y axis
	ball_y_dir:	.word -1	# The ball starts going down
	p1_score:	.word 0
	p2_score: 	.word 0
	computer_count:	.word 0
	computer_speed:	.word 0	
		
	level:		.word 0
	
	points:         .word 0
	
	# The player
	player_x:       .word 0
	player_y:       .word 0
	player_dir:     .word 0x00000000
        player_life:    .word 0
        
        enemy1_x:       .word 0
	enemy1_y:       .word 0
	enemy1_dir:     .word 0
        enemy1_life:    .word 0
        
        enemy2_x:       .word 0
	enemy2_y:       .word 0
	enemy2_dir:     .word 0
        enemy2_life:    .word 0
        
        enemy3_x:       .word 0
	enemy3_y:       .word 0
	enemy3_dir:     .word 0
        enemy3_life:    .word 0

	bomb_active:    .word 0
	bomb_x:         .word 0
	bomb_y:         .word 0
	temp:           .word 0
	
	
.text

new_game:

	jal clear_board
	jal draw_title_screen
	sw zero, KEY_STATUS_ADDRESS, t0
	
	wait:
    	lw t0, KEY_INPUT_ADDRESS # Verify if the player pressed an input
    	li t1, ASCII_SPACE
    	beq t0, t1, one_player_mode
    	
    	li a0, 250
    	li a7, 32
    	ecall
    	
    	j wait # If a key was not pressed go back to the loop
    	
    one_player_mode:
    	li t0, 1
    	sw t0, player_mode, t1
    	j start_game
    	
    start_game:
    	sw zero, KEY_STATUS_ADDRESS, t0 # This clears the status if a key was pressed
    
    j new_round1

    	
# Function: new_round
#	The function does not have parameters, but due to speed internally uses the following convention
#		s0 stores the player dir
#		s1 stores the player x
#		s2
#		s3
# This function is part of the main loop, so it does not require to save the state of the s registers
# but if it were an internal function, it should save each state.
new_round1:
	#Initialize of the required register state for  the new round
	jal clear_board
	li s0, MOV_STAY

	
	sw zero, KEY_STATUS_ADDRESS, t0
	sw zero, bomb_active, t1
	
	li t0, 1
	sw t0, level, t1
	
	li t0, 3
	sw t0, player_life, t1
	
	li t0, 1
	sw t0, enemy1_life, t1
	
	lw a0, p1_score
	li a1, P1_SCORE_COLUMN
	jal draw_score
	
	lw a0, p2_score
	li a1, P2_SCORE_COLUMN
	jal draw_score

	li a0, PLAYER_X1
	li a1, PLAYER_Y1
	sw a0, player_x, t0
	sw a1, player_y, t0
	lw a2, color_red
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X1
	li a1, ENEMY1_Y1
	sw a0, enemy1_x, t0
	sw a1, enemy1_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X2
	li a1, ENEMY1_Y2
	sw a0, enemy2_x, t0
	sw a1, enemy2_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X3
	li a1, ENEMY1_Y3
	sw a0, enemy3_x, t0
	sw a1, enemy3_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	jal draw_frame
	jal draw_erase_block
	jal map_1
	
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay

	j main_game_loop

new_round2:
	jal clear_board
	li s0, MOV_STAY
	li s1, PLAYER_X_START
	
	lw a0, p1_score
	li a1, P1_SCORE_COLUMN
	jal draw_score
	
	lw a0, p2_score
	li a1, P2_SCORE_COLUMN
	jal draw_score
	
	li t0, 3
	sw t0, level, t1
	
	sw zero, KEY_STATUS_ADDRESS, t0
	sw zero, bomb_active, t1
	
	li t0, 3
	sw t0, player_life, t1
	
	li t0, 1
	sw t0, enemy1_life, t1
	
	li a0, PLAYER_X2
	li a1, PLAYER_Y2
	sw a0, player_x, t0
	sw a1, player_y, t0
	lw a2, color_red
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X1
	li a1, ENEMY1_Y1
	sw a0, enemy1_x, t0
	sw a1, enemy1_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X2
	li a1, ENEMY1_Y2
	sw a0, enemy2_x, t0
	sw a1, enemy2_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X3
	li a1, ENEMY1_Y3
	sw a0, enemy3_x, t0
	sw a1, enemy3_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	jal draw_frame
	jal draw_erase_block
	jal map_2
	
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay

	j main_game_loop
	
new_round3:
	jal clear_board
	li s0, MOV_STAY
	li s1, PLAYER_X_START
	
	lw a0, p1_score
	li a1, P1_SCORE_COLUMN
	jal draw_score
	
	lw a0, p2_score
	li a1, P2_SCORE_COLUMN
	jal draw_score
	
	li t0, 5
	sw t0, level, t1
	
	sw zero, KEY_STATUS_ADDRESS, t0
	sw zero, bomb_active, t1
	
	li t0, 3
	sw t0, player_life, t1
	
	li t0, 1
	sw t0, enemy1_life, t1
	
	li a0, PLAYER_X3
	li a1, PLAYER_Y3
	sw a0, player_x, t0
	sw a1, player_y, t0
	lw a2, color_red
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X1
	li a1, ENEMY1_Y1
	sw a0, enemy1_x, t0
	sw a1, enemy1_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	li a0, ENEMY1_X2
	li a1, ENEMY1_Y2
	sw a0, enemy2_x, t0
	sw a1, enemy2_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber

	li a0, ENEMY1_X3
	li a1, ENEMY1_Y3
	sw a0, enemy3_x, t0
	sw a1, enemy3_y, t0
	lw a2, color_cyan
	li a3, MOV_STAY
	jal draw_bomber
	
	jal draw_frame
	jal draw_erase_block
	jal map_3
	
	li a0, 1000
	li a7, 32		
	ecall		# 1 second delay

	j main_game_loop
	
# Function: main_game_loop
# This function is the main game loop of the game when playing
#	The function does not have parameters, but due to speed internally uses the following conventions
#		s0 stores the player dir
#		s1 stores the player x
#               s2 stores the player y
# Return:
# 	void.
main_game_loop:

	.life:
		lw t1, player_life
		beq zero, t1, end_game
			
		li t0, 2
		lw t1, level
		beq t1, t0, new_round2
		li t0, 4
		beq t1, t0, new_round3
		li t0, 6
		beq t1, t0, .player_1_wins
		
		lw t0, p1_score
		li t1, GAME_WIN_POINTS
		beq t0 ,t1, end_game
		
		lw t0, p2_score
		li t1, P2_SCORE_COLUMN
		beq t0 ,t1, end_game
		
	.bomb_logic:
		lw t1, temp            # temp: 0
		li t0, TIME_SEG        # 40
		bge t1, t0, .explosion # t1>40 --->explosion
		
		addi t1, t1, 1         # t1++
		sw t1, temp, t0# se guarda 
		j .bomba_activa
		
	.explosion:
		li t0, 1
		lw t1, bomb_active  #0
		bne t0, t1, .not_draw_bomb # si t0 = 1 cae por gravedad
		sw zero, bomb_active, t1
		
		lw a0, bomb_x
		lw a1, bomb_y
		lw a2, color_yellow2
		jal draw_bomb
		
		# syscall for pausing 10 ms
		li a0, 500
		li a7, 32
		ecall

		
		lw a0, bomb_x
		lw a1, bomb_y
		lw a2, color_black
		jal draw_bomb
	
	.bomba_activa:
		
		li t2, 1
		lw t3, bomb_active
		bne t2, t3, .not_draw_bomb
		
		lw a0, bomb_x
		lw a1, bomb_y
		lw a2, color_yellow
		jal draw_generic_block

	.not_draw_bomb:
		# Player
		lw a0, player_x 
		lw a1, player_y 
		lw a2, color_red
		mv a3, s0
		jal draw_bomber
		sw a0, player_x, t0
		sw a1, player_y, t0
		li s0, MOV_STAY
		
		# syscall for pausing 10 ms
		li a0, 30
		li a7, 32
		ecall
		
		# Enemy
		lw t0, enemy1_life
		beq zero, t0, .dead_1
		
		lw a0, enemy1_x 
		lw a1, enemy1_y 
		lw a2, color_cyan
		mv a3, s0
		jal draw_enemy
		sw a0, enemy1_x, t0
		sw a1, enemy1_y, t0
		
		.dead_1:
	
		lw a0, enemy2_x
		lw a1, enemy2_y
		lw a2, color_cyan
		mv a3, s0
		jal draw_enemy2
		sw a0, enemy2_x, t0
		sw a1, enemy2_y, t0
		
		
		lw a0, enemy3_x
		lw a1, enemy3_y
		lw a2, color_cyan
		mv a3, s0
		jal draw_enemy3
		sw a0, enemy3_x, t0
		sw a1, enemy3_y, t0
		
		j .next	
			lw a0, enemy1_x 
			lw a1, enemy1_y 
			lw a2, color_black
			mv a3, s0
			jal draw_generic_block
		
		.next:
		
		
		jal draw_frame
		
		lw a0, p1_score
		li a1, P1_SCORE_COLUMN
		jal draw_score
		
		lw a0, p2_score
		li a1, P2_SCORE_COLUMN
		jal draw_score
		
		li t1, 1
		li t2, 3
		li t3, 5
		lw t0, level 
		beq t0, t1, .draw_map_1
		beq t0, t2, .draw_map_2
		beq t0, t3, .draw_map_3
		j .begin_standby
		
		.draw_map_1:
		 	jal map_1
		 	j .begin_standby
		
		.draw_map_2:
		 	jal map_2
		 	j .begin_standby
		
		.draw_map_3:
		 	jal map_3
		 	j .begin_standby
# Wait and read inputs
	.begin_standby:
		li t0, 2 # A counter is loaded for an aprox 50ms delay
	
	.standby:
		blez t0, .end_standby
		
		# syscall for pausing 10 ms
		li a0, 5
		li a7, 32
		ecall		
		
		# Decrement counter
		addi t0, t0, -1
		
		# KEY_INPUT_ADDRESS 0xFFFF0004
		# KEY_STATUS_ADDRESS 0xFFFF0000
		# check for a key press
		lw t1, KEY_STATUS_ADDRESS
		blez t1, .end_standby
		
		jal adjust_dir
		sw zero, KEY_STATUS_ADDRESS, t1 # Clean the state that a key has been pressed
		j .standby
	
	.end_standby:
		j .life
		
		
# Function: draw_score
# Parameters:
#	a0: score of the player
#	a1: column of the leftmost scoring dot
# Return:
#	void
draw_score:
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw a0, 12(sp)
	
	mv s0, a0
	mv s1, a1
	li t0, SCORE_FIRST_ROW_POINTS
	ble s0, t0, .score_row_1
	
	.score_row_2:
	li  t0, SCORE_SECOND_ROW_POINTS
	sub t0, s0, t0
	li t1, 1
	sll t0, t0, t1
	add a0, t0, s1 
	li a1, ROW_3
	lw a2, color_white 
	jal draw_point
	
	addi s0, s0, -1
	li t0, SCORE_SECOND_ROW_POINTS
	bge s0, t0, .score_row_2
	
	.score_row_1:
	beq s0, zero, .score_end
	addi t0, s0, -1
	li t1, 1 # I put the number here directly without label because its use is evident
	sll t0, t0, t1
	add a0, t0, s1 
	li a1, ROW_1
	lw a2, color_white 
	jal draw_point
	
	addi s0, s0, -1
	j .score_row_1
	
	.score_end:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw a0, 12(sp)
	addi sp, sp, 16
	
	jr ra
# Function: adjust_dir
# Parameters:
#	None.
# Return:
#	void.
adjust_dir:
	addi sp, sp -4
	sw ra, 0(sp)
	
	lw t0, KEY_INPUT_ADDRESS
	beq t0, zero, .adjust_dir_none
	
	.adjust_dir_left_up:
		li t1, ASCII_W
		bne t0, t1, .adjust_dir_left_down
		li s0, MOV_UP
		j .adjust_dir_done
	
	.adjust_dir_left_down:
		li t1, ASCII_S
		bne t0, t1, .adjust_dir_left_right
		li s0, MOV_DOWN
		j .adjust_dir_done
		
	.adjust_dir_left_right:
		li t1, ASCII_D
		bne t0, t1, .adjust_dir_left_left
		li s0, MOV_RIGHT
		j .adjust_dir_done
		
	.adjust_dir_left_left:
		li t1, ASCII_A
		bne t0, t1, .adjust_dir_space
		li s0, MOV_LEFT
		j .adjust_dir_done
		
	.adjust_dir_space:
		li t1, ASCII_SPACE
		bne t0, t1 .adjust_dir_none
		
		lw t1, bomb_active
		li t0, 1
		beq t0, t1, .adjust_dir_none
		
		sw t0, bomb_active, t1
		lw t0, player_x
		lw t1, player_y
			
		sw t0, bomb_x, t2
		sw t1, bomb_y, t2
		sw zero, temp, t2
		j .adjust_dir_done

	.adjust_dir_none:
		# This section is kept as a case point if the player didn't press a valid option
		li s0, MOV_STAY 

		
	.adjust_dir_done:
		li t0, 97
		sw t0, KEY_INPUT_ADDRESS, t1

		lw ra, 0(sp)
		addi sp, sp, 4
		jr ra

# a0
# a1
# a2
draw_bomb:
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	
	mv s0, a0
	mv s1, a1
	mv s2, a2
	
	.center:
		mv a0, s0
		mv a1, s1
		mv a2, s2
		jal draw_generic_block
		
	.right_col:
		mv a0, s0
		addi a0, a0, 3
		mv a1, s1
		mv a2, s2
		jal draw_generic_block
		
	.left_col:
		mv a0, s0
		addi a0, a0, -3
		mv a1, s1
		mv a2, s2
		jal draw_generic_block
	.down_col:
		mv a0, s0
		mv a1, s1
		addi a1, a1, 3
		mv a2, s2
		jal draw_generic_block
	.up_col:
		mv a0, s0
		mv a1, s1
		addi a1, a1, -3
		
		mv a2, s2
		jal draw_generic_block
		
	.no_mov4:


	# The return values of the new y-top position
	mv a0, s0
	mv a1, s1
	mv a2, s3

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, sp 16
	
	jr ra
	


# Function: draw_bomber
# Parameters:
#	a0: bomber x position
#	a1: bomber y position
#	a2: bomber color
#	a3: bomber direction
# Return:
#	a0: new top y position
#	a1: direction of the bomber
draw_bomber:
	addi sp, sp -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3

	li t0, MOV_STAY
	beq t0, s3, .no_move
	li t0, MOV_DOWN
	beq t0, s3, .down
	li t0, MOV_UP
	beq t0, s3, .up
	li t0, MOV_LEFT
	beq t0, s3, .left
	li t0, MOV_RIGHT
	beq t0, s3, .right
	
	.left:
		mv a0, s0
		mv a1, s1
		addi a0, a0, -1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, -1
		addi a1, a1, 1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, -1
		addi a1, a1, 2
		jal check_collision
		
		li t0, COLLISION # t0 = 1
		beq a0, t0, .no_move

		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a0, a0, 2
		addi a3, a1, 2
		jal draw_vertical_line
		
		addi s0, s0, -1
		j .move
		
	.right:
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		addi a1, a1, 1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		addi a1, a1, 2
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move

		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2
		jal draw_vertical_line
		
		addi s0, s0, 1
		j .move
	
	.up: 
		
		mv a0, s0
		mv a1, s1
		addi a1, a1, -1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 1
		addi a1, a1, -1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 2
		addi a1, a1, -1
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a1, a1, 2
		addi a3, a0, 2
		jal draw_horizontal_line
	
		addi s1, s1, -1
		j .move
			
	.down:
		mv a0, s0
		mv a1, s1
		addi a1, a1, 3
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 1
		addi a1, a1, 3
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 2
		addi a1, a1, 3
		jal check_collision
		
		li t0, COLLISION
		beq a0, t0, .no_move
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a0, 2
		jal draw_horizontal_line
		
		addi s1, s1, 1
		j .move
	
	.no_move:
		#set the return value to MOV_STAY
		li s3, MOV_STAY
		
#	a0: paddle x position
#	a1: paddle top y position
#	a2: paddle color
#	a3: paddle direction
	
	.move:
		mv a0, s0
		mv a1, s1
		mv a2, s2
		jal draw_generic_block
	# The return values of the new y-top position
	mv a0, s0
	mv a1, s1
	mv a2, s3

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp 20
	
	jr ra

# Function: draw_enemy
# Parameters:
#	a0: paddle x position
#	a1: paddle top y position
#	a2: paddle color
#	a3: paddle direction
# Return:
#	a0: new top y position
#	a1: direction of the paddle
draw_enemy:
	addi sp, sp -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	
	lw s3, enemy1_dir

	li t0, MOV_STAY
	beq t0, s3, .no_mov
	li t0, MOV_DOWN
	beq t0, s3, .mov_down
	li t0, MOV_UP
	beq t0, s3, .mov_up
	li t0, MOV_LEFT
	beq t0, s3, .mov_left
	li t0, MOV_RIGHT
	beq t0, s3, .mov_right

	.mov_up: 
		
		li t0, TOP_PADDLE_Y_ROW
		beq s1, t0, .no_mov

		mv a0, s0
		mv a1, s1
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov

		mv a0, s0   
		mv a1, s1
		addi a0, a0, 1		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0   
		mv a1, s1
		addi a0, a0, 2		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
	
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a1, a1, 2
		addi a3, a0, 2
		jal draw_horizontal_line	
		
		addi s1, s1, -1
		j .mov
			
	.mov_down:
		
		mv a0, s0
		mv a1, s1
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 1		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 2		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		

		mv a0, s0 # x
		mv a1, s1 # y
		lw a2, color_black
		addi a3, a0, 2
		jal draw_horizontal_line

		addi s1, s1, 1
		j .mov
		
	.mov_left:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		addi a0, a0, 2
		jal draw_vertical_line
		

		addi s0, s0, -1
		j .mov
		
	.mov_right:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		jal draw_vertical_line

		addi s0, s0, 1
		j .mov 
	
	.no_mov:
		jal generate_random1
		sw a3, enemy1_dir, t0

	.mov:
		mv a0, s0
		mv a1, s1
		mv a2, s2
		jal draw_generic_block

	# The return values of the new y-top position
	mv a0, s0
	mv a1, s1
	mv a2, s3

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp 20
	
	jr ra
end_game:
	jal clear_board

	lw t0, p1_score
	li t1, GAME_WIN_POINTS
	
	bne t0, t1, .player_2_wins
	
	.player_1_wins:
	jal clear_board
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 1
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 2
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 3
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 4
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 5
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 3
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 8
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 8
	li a1, PRESS_TEXT_Y
	addi a1, a1, PRESS_TEXT_H
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	# THE N
	li a0, PRESS_TEXT_X
	addi a0, a0,14
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0,14
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0,15
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0,16
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0,17
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	j .pause
		
	.player_2_wins:
	# GAME OVER
	# The G
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	addi a1, a1, PRESS_TEXT_H
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	# The A
	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 9
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 8
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The M
	li a0, PRESS_TEXT_X
	addi a0, a0, 12
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 16
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line #13421

	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line #13421	
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 15
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 14
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	# The E
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	addi a1, a1, PRESS_TEXT_H
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	# The O
	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	li a1, PRESS_TEXT_Y
	addi a1, a1, PRESS_TEXT_H
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 25
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line #13421
	
	# The V
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 31
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 31
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 32
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 34
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 33
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line 
	
	# The E
	li a0, PRESS_TEXT_X
	addi a0, a0, 37
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 37
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 37
	li a1, PRESS_TEXT_Y
	addi a1, a1, PRESS_TEXT_H
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 37
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	# The R 2211
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	addi a0, a0, PRESS_TEXT_H
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, PRESS_TEXT_H
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line

		
	j .pause

	.pause:
		li a0, 3000
		li a7, 32	
		ecall		#Pause for 100 milisec
		
	jal clear_key_status
	
	.reset_wait:
		li a0, 10
		li a7, 32 
		ecall		#Pause for 100 milisec
		
		li t0, KEY_STATUS_ADDRESS
		beq t0, zero, .reset_wait
		
		j .reset
	
	.reset:
		sw zero, p1_score, t0
		sw zero, p2_score, t0
		jal clear_key_status
		jal clear_key_press
		
		jal clear_board
		
		j new_game
draw_enemy2:
	addi sp, sp -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	
	lw s3, enemy2_dir

	li t0, MOV_STAY
	beq t0, s3, .no_mov2
	li t0, MOV_DOWN
	beq t0, s3, .mov_down2
	li t0, MOV_UP
	beq t0, s3, .mov_up2
	li t0, MOV_LEFT
	beq t0, s3, .mov_left2
	li t0, MOV_RIGHT
	beq t0, s3, .mov_right2

	.mov_up2: 
		
		li t0, TOP_PADDLE_Y_ROW
		beq s1, t0, .no_mov2

		mv a0, s0
		mv a1, s1
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2

		mv a0, s0   
		mv a1, s1
		addi a0, a0, 1		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0   
		mv a1, s1
		addi a0, a0, 2		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
	
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a1, a1, 2
		addi a3, a0, 2
		jal draw_horizontal_line	
		
		addi s1, s1, -1
		j .mov2
			
	.mov_down2:
		
		mv a0, s0
		mv a1, s1
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 1		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 2		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		

		mv a0, s0 # x
		mv a1, s1 # y
		lw a2, color_black
		addi a3, a0, 2
		jal draw_horizontal_line

		addi s1, s1, 1
		j .mov2
		
	.mov_left2:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		addi a0, a0, 2
		jal draw_vertical_line
		

		addi s0, s0, -1
		j .mov2
		
	.mov_right2:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov2
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		jal draw_vertical_line

		addi s0, s0, 1
		j .mov2
	
	.no_mov2:
			li a0, 1234
	rdtime a1
	xor a1, a1, a0
    	li a2, 4
    	remu a0, a1, a2
    	addi a0, a0, 1
    	add a3, zero, a0
		sw a3, enemy2_dir, t0

	.mov2:
		mv a0, s0
		mv a1, s1
		mv a2, s2
		jal draw_generic_block

	# The return values of the new y-top position
	mv a0, s0
	mv a1, s1
	mv a2, s3

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp 20
	
	jr ra

draw_enemy3:
	addi sp, sp -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	
	lw s3, enemy3_dir

	li t0, MOV_STAY
	beq t0, s3, .no_mov3
	li t0, MOV_DOWN
	beq t0, s3, .mov_down2
	li t0, MOV_UP
	beq t0, s3, .mov_up3
	li t0, MOV_LEFT
	beq t0, s3, .mov_left3
	li t0, MOV_RIGHT
	beq t0, s3, .mov_right3

	.mov_up3: 
		
		li t0, TOP_PADDLE_Y_ROW
		beq s1, t0, .no_mov3

		mv a0, s0
		mv a1, s1
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3

		mv a0, s0   
		mv a1, s1
		addi a0, a0, 1		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0   
		mv a1, s1
		addi a0, a0, 2		
		addi a1, a1 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
	
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a1, a1, 2
		addi a3, a0, 2
		jal draw_horizontal_line	
		
		addi s1, s1, -1
		j .mov3
			
	.mov_down3:
		
		mv a0, s0
		mv a1, s1
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 1		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 2		# Inferior derecha (Colision)
		addi a1, a1, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		

		mv a0, s0 # x
		mv a1, s1 # y
		lw a2, color_black
		addi a3, a0, 2
		jal draw_horizontal_line

		addi s1, s1, 1
		j .mov3
		
	.mov_left3:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0 -1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, -1		# inferior izquierda (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		addi a0, a0, 2
		jal draw_vertical_line
		

		addi s0, s0, -1
		j .mov3
		
	.mov_right3:
		
		mv a0, s0
		mv a1, s1
		addi a0, a0, 3
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3

		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 1
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0   		#Devolviendo coordenadas del jugador
		mv a1, s1
		addi a0, a0, 3		#inferior derecha (Colision)
		addi a1, a1, 2
		jal check_enemy_collision
		
		li t0, COLLISION
		beq a0, t0, .no_mov3
		
		mv a0, s0
		mv a1, s1
		lw a2, color_black
		addi a3, a1, 2# donde termina Y
		jal draw_vertical_line

		addi s0, s0, 1
		j .mov3
	
	.no_mov3:
			li a0, 1234
	rdtime a1
	xor a1, a1, a0
    	li a2, 4
    	remu a0, a1, a2
    	addi a0, a0, 1
    	add a3, zero, a0
		sw a3, enemy3_dir, t0

	.mov3:
		mv a0, s0
		mv a1, s1
		mv a2, s2
		jal draw_generic_block

	# The return values of the new y-top position
	mv a0, s0
	mv a1, s1
	mv a2, s3

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp 20
	
	jr ra

generate_random1:
	

	li a0, 1234
	rdtime a1
	xor a1, a1, a0
    	li a2, 4
    	remu a0, a1, a2
    	addi a0, a0, 1
    	add a3, zero, a0
        ret

        
generate_random2:

	
	li a0, 1234
	rdtime a1
	xor a1, a1, a0
    	li a2, 4
    	remu a0, a1, a2
    	addi a0, a0, 1
    	add a3, zero, a0
        ret
        

        
generate_random3:

	li a0, 1234
	rdtime a1
	xor a1, a1, a0
    	li a2, 4
    	remu a0, a1, a2
    	addi a0, a0, 1
    	add a3, zero, a0
        ret
        
# a0 = x
# a1 = y
check_enemy_collision:
	addi sp, sp -4
	sw ra, 0(sp)
	
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	lw t2, (t1)
	
	lw t0, color_orange
	beq t0, t2, .enemy_collision
	
	lw t0, color_yellow
	beq t0, t2, .coll_bomb

	lw t0, color_silver
	beq t0, t2, .enemy_collision

	lw t0, color_cyan
	beq t0, t2, .enemy_collision

	lw t0, color_yellow2
	beq t0, t2, .coll_bomb
	
	lw t0, color_red
	#beq t0, t2, .coll_red
	
	lw t0, color_black
	bne t0, t2, .enemy_collision

	.no_enemy_collision:
		li a0, NO_COLLISION
		j .check_enemy_collision_exit
		
	.coll_bomb:
		li a0,NO_COLLISION
		
		lw t0, p1_score
		addi t0, t0, 1
		sw t0, p1_score, t1
		
		sw zero, enemy1_life, t6

		j .check_enemy_collision_exit
		
	.coll_red:
		li a0, COLLISION
		
		lw t1, player_life
		addi t1, t1 -1
		sw t1, player_life, t6
		
		lw t0, p2_score
		addi t0, t0, 1
		sw t0, p2_score, t1
		
		sw zero, enemy1_life, t6
		
		j .check_enemy_collision_exit
	
	
	.enemy_collision:
		li a0, COLLISION

	.check_enemy_collision_exit:
		lw ra, 0(sp)
		addi sp, sp, 4
		jr ra

# a0 = x
# a1 = y
check_collision:
	addi sp, sp -4
	sw ra, 0(sp)
	
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	lw t2, (t1)
	
	lw t0, color_yellow2
	beq t0, t2, .self_bomb
	
	lw t0, color_yellow
	beq t0, t2, .collision
	
	lw t0, color_orange
	beq t0, t2, .collision
	
	lw t0, color_green
	beq t0, t2, .collision
	
	lw t0, color_purple
	beq t0, t2, .portal_col

	lw t0, color_cyan
	beq t0, t2, .collision

	lw t0, color_black
	bne t0, t2, .collision

	.no_collision:
		li a0, NO_COLLISION
		j .check_collision_exit
	
	.collision:
		li a0, COLLISION
		j .check_collision_exit
		
	.portal_col:
		li a0, COLLISION
		
		lw t0, level
		addi t0, t0, 1
		sw t0, level, t1
		j .check_collision_exit
		
	.self_bomb:
		li a0, COLLISION
		
		lw t1, player_life
		addi t1, t1 -1
		sw t1, player_life, t6
		
		j .check_collision_exit
	

	.check_collision_exit:
	
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
	


# Funtion: LoadColor
# Parameters:
#	a0: x coordinate
#	a1: y coordinate
#	a2: color of the point
# Return
#	a0 = color of point
load_color:
	addi sp, sp, -4
	sw ra, 0(sp)
		
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	lw a0, (t1)
	
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra

# Function: draw_point
# Parameters:
#	a0: x coordinate
#	a1: y coordinate
#	a2: color of the point
# Return
#	void
draw_point:
	li t0, 6
	sll t0, a1, t0 #Due to the size of the screen, multiply y coodinate by 64 (length of the field)
	add t1, a0, t0
	li t0, 2
	sll t1, t1, t0 # Multiply the resulting coodinate by 4
	add t1, t1, gp
	sw a2, (t1)
	jr ra

# Function: draw_horizontal_line
# Parameters:
#	a0: starting x coordinate
#	a1: y coordinate
#	a2: color of the line
#	a3: ending x coordinate
# Return
#	void
draw_horizontal_line:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	
	sub s0, a3, a0
	mv s1, a0
	li s2, 0
	
	.horizontal_loop:
		add a0, s1, s0
		jal draw_point
		addi s0, s0, -1
		
		bge s0, s2, .horizontal_loop
	
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, sp, 16	
	
	jr ra

# Function: draw_vertical_line
# Parameters:
#	a0: x coordinate
#	a1: starting y coordinate
#	a2: color of the line
#	a3: ending y coordinate
# Return
#	void
draw_vertical_line:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	
	sub s0, a3, a1
	mv s1, a1
	li s2, 0
	
	.vertical_loop:
		add a1, s1, s0
		jal draw_point
		addi s0, s0, -1
		
		bge s0, s2, .vertical_loop
	
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	
	addi sp, sp, 16	
	
	jr ra
	
# Function: clear_board
# Parameters:
#	none
# Return
#	void
clear_board:
	lw t0, color_black
	li t1, TOTAL_PIXELS
	li t2, FOUR_BYTES
	
	.start_clear_loop:
		sub t1, t1, t2 # Se limpia de 4 en 4 cada ciclo de loop
		add t3, t1, gp # se suma a la dirrecion gp (Global Pointer)
		sw t0, (t3)
		beqz t1, .end_clear_loop # Si t1 = 0 se acaba el loop
		j .start_clear_loop
		
	.end_clear_loop:
	
	jr ra
	
	

	
# Function: draw_frame
# Parameters:
#	none
# Return
#	void
draw_frame:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li a0, 5
	li a1, 2
	lw a2, color_orange
	li a3, 57
	jal draw_horizontal_line
	
	li a0, 5
	li a1, 30
	lw a2, color_orange
	li a3, 57
	jal draw_horizontal_line
	
	li a0, 5
	li a1, 3
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line
	
	li a0, 57
	li a1, 3
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line
	
				
	lw ra, 0(sp)
	addi sp, sp, 4
	
	jr ra 

map_1:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	jal draw_silver_block
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 6
	jal draw_silver_block
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 12
	jal draw_silver_block
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 18
	jal draw_silver_block
	
	lw ra,0(sp)
	addi sp, sp, 4
	jr ra

map_2:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 12
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 12
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 12
	jal draw_silver_block
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 18
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 18
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 18
	jal draw_silver_block
	
	lw ra,0(sp)
	addi sp, sp, 4
	jr ra
	
map_3:
	addi sp, sp, -4
	sw ra, 0(sp)
	


	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	jal draw_silver_block
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 6
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 6
	jal draw_silver_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 18
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 36
	addi a1, a1, 6
	jal draw_silver_block

	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 42
	addi a1, a1, 6
	jal draw_silver_block
	################################################################################################

	
	lw ra,0(sp)
	addi sp, sp, 4
	jr ra

draw_erase_block:
	addi sp, sp, -4
	sw ra, 0(sp)
	
	################################################################################################
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, -3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 15
	lw a2, color_green
	jal draw_generic_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, -3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 12
	addi a1, a1, 9
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 21
	addi a1, a1, 12
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 21
	addi a1, a1, 18
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 24
	addi a1, a1, 15
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 21
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 15
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 9
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, -3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 30
	addi a1, a1, 3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 39
	addi a1, a1, 3
	lw a2, color_purple
	jal draw_generic_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 15
	addi a1, a1, 18
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 9
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a0, a0, 3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 3
	jal draw_green_block
	
	li a0, MAP_1_X
	li a1, MAP_1_Y
	addi a1, a1, 9
	jal draw_green_block
	
	lw ra,0(sp)
	addi sp, sp, 4
	jr ra
# a0 pos x
# a1 pos y
# a2 color
# a3 ending 
draw_generic_block:
	
	addi sp, sp, -20
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	sw a3, 12(sp)
	sw a2, 16(sp)
		
	addi a3, a0, 2    
	jal draw_horizontal_line
		
	addi a1, a1, 1
	addi a3, a0, 2
	jal draw_horizontal_line
	
	addi a1, a1, 1
	addi a3, a0, 2
	jal draw_horizontal_line
		
	lw ra, 0(sp)
	lw a0, 4(sp)
	lw a1, 8(sp)
	lw a3, 12(sp)
	lw a2, 16(sp)
	addi sp, sp, 20
		
	jr ra
# $a0 pos x
# $a1 pos y
draw_silver_block:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	sw a3, 12(sp)
		
		
	lw a2, color_silver
	addi a3, a0, 2    
	jal draw_horizontal_line
		
	addi a1, a1, 1
	lw a2, color_silver
	addi a3, a0, 2
	jal draw_horizontal_line
	
	addi a1, a1, 1
	lw a2, color_silver
	addi a3, a0, 2
	jal draw_horizontal_line
		
	lw ra, 0(sp)
	lw a0, 4(sp)
	lw a1, 8(sp)
	lw a3, 12(sp)
	addi sp, sp, 16
		
	jr ra

# $a0 pos x
# $a1 pos y
draw_green_block:
	
	addi sp, sp, -16
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	sw a3, 12(sp)
		
	
	lw a2, color_green
	addi a3, a0, 2    
	jal draw_horizontal_line
		
	addi a1, a1, 1
	lw a2, color_green
	addi a3, a0, 2
	jal draw_horizontal_line
	
	addi a1, a1, 1
	lw a2, color_green
	addi a3, a0, 2
	jal draw_horizontal_line
		
	lw ra, 0(sp)
	lw a0, 4(sp)
	lw a1, 8(sp)
	lw a3, 12(sp)
	addi sp, sp, 16
		
	jr ra

# Function: draw_title_screen
# Parameters:
#	none
# Return
#	void
draw_title_screen:

	addi sp, sp, -4
	sw ra, 0(sp)

	# The upper lines
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	lw a2, color_orange
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 1
	lw a2, color_orange
	li a3, 63
	jal draw_horizontal_line

	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 30
	lw a2, color_orange
	li a3, 63
	jal draw_horizontal_line

	li a0, 0
	li a1, TITLE_SCREEN_FIRST_LINE_ROW_Y
	addi a1, a1, 31
	lw a2, color_orange
	li a3, 63
	jal draw_horizontal_line
	
	li a0, 0
	li a1, 2
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line
	
	li a0, 1
	li a1, 2
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line
	
	li a0, 63
	li a1, 2
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line
	
	li a0, 62
	li a1, 2
	lw a2, color_orange
	li a3, 29
	jal draw_vertical_line

	# Pong text
	
	# Bomber Tec text
	
	# The B
	li a0, 4
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, PONG_TEXT_Y
	jal draw_vertical_line
	
	li a0, 8
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line

	li a0, 5
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, 5
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, 5
	li a1, PONG_TEXT_Y
	addi a1, a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, 8
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	jal draw_point
	
	# The O
	li a0, 10
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 14
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 10
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line

	li a0, 10
	li a1, PONG_TEXT_Y
	addi a1,  a1, 5
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	# The M
	
	li a0, 16
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 20
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 18
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 2
	jal draw_vertical_line
	
	li a0, 19
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, 17
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	# The B
	li a0, 22 #17
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, PONG_TEXT_Y
	jal draw_vertical_line
	
	li a0, 26
	li a1, PONG_TEXT_Y 
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 26
	li a1, PONG_TEXT_Y 
	addi a1, a1, 1
	lw a2, color_white
	jal draw_point

	li a0, 22
	li a1, PONG_TEXT_Y 
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	li a0, 22
	li a1, PONG_TEXT_Y 
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	li a0, 22
	li a1, PONG_TEXT_Y 
	addi a1, a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	# The E
	li a0, 28
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 29
	li a1, PONG_TEXT_Y 
	addi a1, a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	li a0, 29
	li a1, PONG_TEXT_Y 
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	li a0, 29
	li a1, PONG_TEXT_Y 
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 3
	jal draw_horizontal_line
	
	# The R
	
	li a0, 34
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, PONG_TEXT_H
	jal draw_vertical_line #2211
	
	li a0, 37
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 37
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_black
	jal draw_point
	
	li a0, 35
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, 36
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, 35
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, 36
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	# The M
	
	li a0, 42
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line #4231
	
	li a0, 46
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 44
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, 2
	jal draw_vertical_line
	
	li a0, 45
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, 43
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	# The A
	
	li a0, 48
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line #13421
	
	li a0, 49
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 51
	li a1, PONG_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 52
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 2
	jal draw_vertical_line
	
	li a0, 50
	li a1, PONG_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, 49
	li a1, PONG_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The N
	li a0, 54
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	li a0, 55
	li a1, PONG_TEXT_Y
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 56
	li a1, PONG_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 57
	li a1, PONG_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, 58
	li a1, PONG_TEXT_Y
	lw a2, color_white
	li a3, PONG_TEXT_Y
	addi a3, a3, PONG_TEXT_H
	jal draw_vertical_line
	
	# Press Space
	
	# The P
	li a0, PRESS_TEXT_X
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 3
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 1
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 1
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The R
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 5
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 7
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 6
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
			
	#The E
	li a0, PRESS_TEXT_X
	addi a0, a0, 9
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 10
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	jal draw_point
	
	# The first S
	li a0, PRESS_TEXT_X
	addi a0, a0, 12
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 12
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 13
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 14
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 14
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point

	# The other S
		
	li a0, PRESS_TEXT_X
	addi a0, a0, 16
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 16
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 17
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X
	addi a0, a0, 18
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point
	
	# The other S
		
	li a0, PRESS_TEXT_X
	addi a0, a0, 22
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 22
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, PRESS_TEXT_X#1
	addi a0, a0, 23
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X#1
	addi a0, a0, 23
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X#1
	addi a0, a0, 23
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, PRESS_TEXT_X#2
	addi a0, a0, 24
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line

	li a0, PRESS_TEXT_X#2
	addi a0, a0, 24
	li a1, PRESS_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point
	
	# The P
	li a0, PRESS_TEXT_X
	addi a0, a0, 26
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 29
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 27
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 27
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The A
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 31
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line #13421
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 32
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 34
	li a1, PRESS_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 35
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 33
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, PRESS_TEXT_X
	addi a0, a0, 32
	li a1, PRESS_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The C 
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 37
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 38
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 38
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The E
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 42
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, PRESS_TEXT_X
	addi a0, a0, 43
	li a1, PRESS_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	
	# The name////////////////////////////////////////////////////////////////////////////////
		
	# The S
		
	li a0, NAME_TEXT_X
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_black
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 1
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 1
	li a1, NAME_TEXT_Y
	addi a1,  a1, 2
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X
	addi a0, a0, 1
	li a1, NAME_TEXT_Y
	addi a1,  a1, 4
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 2
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line

	li a0, NAME_TEXT_X
	addi a0, a0, 2
	li a1, NAME_TEXT_Y
	addi a1,  a1, 1
	lw a2, color_black
	jal draw_point																																																																																																																							
																																																																																																																																																																																							
				
	#The E
	li a0, NAME_TEXT_X
	addi a0, a0, 4
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, PRESS_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 5
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 5
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 5
	li a1, NAME_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	jal draw_point		
	
	
	# The R 
	
	li a0, NAME_TEXT_X
	addi a0, a0, 9
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 7
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 9
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_black
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 8
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X
	addi a0, a0, 8
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	# The G
	
	li a0, NAME_TEXT_X
	addi a0, a0, 11
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 14
	li a1, NAME_TEXT_Y
	addi a1,a1,3
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 12
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	
	li a0, NAME_TEXT_X
	addi a0, a0, 12
	li a1, NAME_TEXT_Y
	addi a1, a1, 4
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 13
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 1
	jal draw_horizontal_line
	
	# The I
	li a0, NAME_TEXT_X
	addi a0, a0, 16
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 17
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 16
	li a1, NAME_TEXT_Y
	addi a1, a1, NAME_TEXT_H
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The O
	
	li a0, NAME_TEXT_X
	addi a0, a0, 20
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line

	li a0, NAME_TEXT_X
	addi a0, a0, 22
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line		
	
	li a0, NAME_TEXT_X
	addi a0, a0, 21
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X
	addi a0, a0, 21
	li a1, NAME_TEXT_Y
	addi a1, a1, NAME_TEXT_H
	lw a2, color_white
	jal draw_point
	
	# The Z
	
	li a0, NAME_TEXT_X
	addi a0, a0, 26
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a0, 4
	jal draw_horizontal_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 26
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 27
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 28
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 29
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 30
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	jal draw_point
	
	li a0, NAME_TEXT_X
	addi a0, a0, 26
	li a1, NAME_TEXT_Y
	addi a1, a1, NAME_TEXT_H
	lw a2, color_white
	addi a3, a0, 4
	jal draw_horizontal_line
	
	
	# The A
	
	li a0, NAME_TEXT_X
	addi a0, a0, 32
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 33
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 35
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 36
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 34
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X
	addi a0, a0, 33
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The P
	li a0, NAME_TEXT_X
	addi a0, a0, 38
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a1, NAME_TEXT_H
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 41
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 39
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 39
	li a1, NAME_TEXT_Y
	addi a1, a1, 2
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The A
	
	li a0, NAME_TEXT_X
	addi a0, a0, 43
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 44 #1
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 46 #3
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X #4
	addi a0, a0, 47
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X #2
	addi a0, a0, 45
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X #1
	addi a0, a0, 44
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	# The T
	
	li a0, NAME_TEXT_X #1
	addi a0, a0, 48
	li a1, NAME_TEXT_Y
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 49 #2
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 3
	jal draw_vertical_line
	
	# The A
	
	li a0, NAME_TEXT_X
	addi a0, a0, 51
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 52 #1
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X
	addi a0, a0, 54 #3
	li a1, NAME_TEXT_Y
	addi a1, a1, 1
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X #4
	addi a0, a0, 55
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a1, 1
	jal draw_vertical_line
	
	li a0, NAME_TEXT_X #2
	addi a0, a0, 53
	li a1, NAME_TEXT_Y
	lw a2, color_white
	jal draw_point

	li a0, NAME_TEXT_X #1
	addi a0, a0, 52
	li a1, NAME_TEXT_Y
	addi a1, a1, 3
	lw a2, color_white
	addi a3, a0, 2
	jal draw_horizontal_line
			
			
	lw ra, 0(sp)
	addi sp, sp, 4
	
	jr ra 


# Function: clear_key_press
# Parameters:
# 	none.
# Return:
#	void.
clear_key_press:
	sw zero, KEY_INPUT_ADDRESS, t0
	jr ra
	
# Function: clear_key_status
# Parameters:
# 	none.
# Return:
#	void.
clear_key_status:
	sw zero, KEY_STATUS_ADDRESS, t0
	jr ra
end:

j end
