import '../../models/exercise_model.dart';

class DefaultExercises {
  static final List<Exercise> list = [
    Exercise(
      id: 'chest-bb-bench-press',
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie back on flat bench. Grip barbell slightly wider than shoulder-width.
2. Retract shoulder blades, plant feet flat, puff chest.
3. Lower bar with control to mid-chest (nipple line).
4. Press bar upward explosively extending elbows.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-incline-bb-press',
      name: 'Incline Barbell Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on an incline bench angled at 30° to 45°.
2. Grip the barbell slightly wider than shoulder-width.
3. Lower bar smoothly to upper clavicular chest.
4. Drive bar straight up until arms are fully extended.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-decline-bb-press',
      name: 'Decline Barbell Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Secure legs in decline bench pads and lie back.
2. Grasp barbell with an overhand grip wider than shoulder-width.
3. Lower bar smoothly to your lower chest/sternum.
4. Push forcefully upward back to starting locked position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-db-bench-press',
      name: 'Flat Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on flat bench with dumbbells on knees. Kick back into position.
2. Hold dumbbells at chest level with elbows at ~45-60° angle.
3. Press dumbbells upward until arms are straight without clanking.
4. Lower slowly under deep pec control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-incline-db-press',
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Position bench at 30-45°. Kick dumbbells up to shoulder height.
2. Retract scapulae and keep chest elevated.
3. Press dumbbells vertically and slightly inward.
4. Lower under control for maximum upper chest stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-decline-db-press',
      name: 'Decline Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hook feet under decline rollers and hold dumbbells at chest level.
2. Press dumbbells upward over lower pecs.
3. Lower with control until weights are parallel with chest.
4. Drive back up focusing on lower chest contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-db-fly',
      name: 'Flat Dumbbell Fly',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on bench with dumbbells above chest, palms facing each other.
2. Maintain a slight fixed elbow bend throughout.
3. Open arms in a wide hugging arc until chest is stretched.
4. Contract pecs to bring dumbbells back together.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-incline-db-fly',
      name: 'Incline Dumbbell Fly',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set bench to 30° incline. Hold dumbbells overhead palms facing inward.
2. Lower weights out wide feeling deep clavicular chest stretch.
3. Pull dumbbells back up in a hugging arc.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-decline-db-fly',
      name: 'Decline Dumbbell Fly',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on decline bench holding dumbbells over lower chest.
2. Open arms in wide arc with elbows slightly bent.
3. Squeeze lower pectoral fibers to bring weights back together.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-cable-crossover-high',
      name: 'Cable High-to-Low Fly',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set pulleys high. Step forward into staggered stance with forward lean.
2. Bring handles downward and inward toward hips in an arc.
3. Squeeze lower pecs forcefully at bottom for 1 second.
4. Return to starting stretch with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-cable-fly-low',
      name: 'Cable Low-to-High Fly',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set pulleys at floor level. Hold handles palms facing forward.
2. Sweep handles upward and inward toward eye level.
3. Squeeze upper chest hard at peak, then control descent.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-cable-mid-fly',
      name: 'Cable Middle Fly (Chest Level)',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set pulleys at nipple height. Take one step forward in athletic stance.
2. Bring handles together directly in front of chest in a wide arc.
3. Squeeze inner and mid pecs intensely for 1 second.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-cable-standing-press',
      name: 'Standing Cable Chest Press',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set cable pulleys at shoulder height and grip handles facing away.
2. Step forward into split stance with core braced.
3. Press cables straight forward extending elbows.
4. Control eccentric return without letting elbows hyper-extend back.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-pec-deck',
      name: 'Pec Deck Machine Fly',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Adjust seat so handles align with mid-chest.
2. Keep back flat against backrest and chest puffed.
3. Squeeze handles together until pads touch in front of you.
4. Hold peak squeeze for 1 second, then control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-press-machine',
      name: 'Chest Press Machine',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Adjust seat so handles line up with mid-chest.
2. Plant feet and push back into backrest.
3. Press forward until arms are almost fully extended.
4. Return with control feeling deep pectoral stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-incline-machine-press',
      name: 'Incline Chest Press Machine',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine and align handles with upper chest.
2. Press upward along machine track focusing on upper pecs.
3. Lower with control until comfortable stretch is achieved.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-decline-machine-press',
      name: 'Decline Chest Press Machine',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust seat and grip handles aligned with lower sternum.
2. Press handles downward and forward focusing on lower chest.
3. Slowly return weight to starting position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-smith-bench-press',
      name: 'Smith Machine Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Position flat bench directly under Smith machine bar at mid-chest.
2. Unhook bar with shoulder-width grip and rotate wrists.
3. Lower under strict tempo to lightly touch chest.
4. Drive up forcefully through chest and heels.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-smith-incline-press',
      name: 'Smith Machine Incline Press',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set incline bench at 30-45° under Smith bar.
2. Unrack bar and lower carefully to upper chest.
3. Press up along fixed path to maintain constant clavicular tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-smith-decline-press',
      name: 'Smith Machine Decline Press',
      muscleGroup: 'Chest',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set decline bench under Smith bar so it lands on lower sternum.
2. Unrack and lower bar smoothly under control.
3. Press barbell back up focusing on lower chest recruitment.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-dips',
      name: 'Chest Dips',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Mount parallel bars with straight arms.
2. Lean torso forward ~30° with elbows flared slightly out.
3. Lower body until shoulders drop below elbows.
4. Drive through palms to return to top position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-weighted-dips',
      name: 'Weighted Chest Dips',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Fasten weight belt with plate or hold dumbbell between ankles.
2. Mount bars, lean torso forward ~30° throughout.
3. Lower smoothly into deep stretch below parallel.
4. Press back up powerfully focusing on lower pec drive.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-push-up',
      name: 'Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hands slightly wider than shoulder-width in high plank position.
2. Keep core and glutes engaged in a straight line.
3. Lower chest to floor with elbows angled at 45°.
4. Push ground away powerfully back to plank.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-diamond-push-up',
      name: 'Diamond Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place thumbs and index fingers touching under chest to form diamond.
2. Lower chest until it gently touches your hands.
3. Push up emphasizing inner chest and triceps.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-wide-push-up',
      name: 'Wide Grip Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place hands about 1.5x shoulder-width apart in plank stance.
2. Lower torso until chest touches floor feeling maximum pec stretch.
3. Push up contracting outer and mid pecs.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-decline-push-up',
      name: 'Decline Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place feet elevated on bench or box with hands on floor.
2. Lower chest down toward floor at steep downward angle.
3. Press up to target upper clavicular chest fibers.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-incline-push-up',
      name: 'Incline Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place hands on elevated bench or bar with feet on floor.
2. Lower chest down to touch the edge of elevated surface.
3. Press away emphasizing lower chest contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-deficit-push-up',
      name: 'Deficit Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Place hands elevated on weight plates or blocks.
2. Lower body deeper than floor level for an intense pec stretch.
3. Push up powerfully back to the top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-ring-push-up',
      name: 'Gymnastic Ring Push Up',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Adjust gymnastics rings a few inches above floor.
2. Hold rings in push-up plank, stabilizing against sway.
3. Descend deeply, then press up and turn rings inward for max pec squeeze.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-db-pullover',
      name: 'Dumbbell Pullover',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie perpendicularly across flat bench supporting upper back/neck.
2. Hold dumbbell overhead with diamond grip using both palms.
3. Lower dumbbell in an arc behind head while dropping hips slightly.
4. Pull dumbbell back up over chest using chest and serratus.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-bb-floor-press',
      name: 'Barbell Floor Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on floor under barbell racked in power rack.
2. Unrack bar and lower until triceps touch floor smoothly.
3. Pause for split second eliminating momentum, then press bar upward.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-db-floor-press',
      name: 'Dumbbell Floor Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on floor with dumbbells pressed above chest.
2. Lower dumbbells until back of upper arms rests on floor.
3. Pause briefly, then drive dumbbells upward.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-landmine-press',
      name: 'Landmine Chest Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold end of landmine barbell with both hands at chest level.
2. Press barbell up and forward at a 45° angle.
3. Squeeze upper and inner chest hard at full extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-svend-press',
      name: 'Svend Press (Plate Squeeze)',
      muscleGroup: 'Chest',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand upright holding two small weight plates squeezed together at chest.
2. Press arms straight out in front of chest while squeezing plates tightly.
3. Pull back to chest under constant tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'chest-cable-iron-cross',
      name: 'Cable Iron Cross',
      muscleGroup: 'Chest',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set high pulleys on both sides. Hold handles with arms in T-pose.
2. Pull cables straight down to your sides in an arc using lower pecs.
3. Hold contraction against thighs for 1 second, then control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-bb-deadlift',
      name: 'Conventional Barbell Deadlift',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand feet hip-width under bar, bar over midfoot.
2. Hinge at hips, grip bar outside knees.
3. Set back flat, pull chest up, brace core, take slack out of bar.
4. Drive floor away through heels, extending hips and knees simultaneously.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-sumo-deadlift',
      name: 'Sumo Deadlift',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Take wide stance with toes pointed out toward plates.
2. Grip barbell inside knees with arms vertical.
3. Drop hips, wedge torso upright, pull chest tall.
4. Drive through heels and spread floor apart to lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-deficit-deadlift',
      name: 'Deficit Deadlift',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand on a 1-3 inch platform or bumper plate.
2. Hinge deep to grip barbell, keeping flat neutral spine.
3. Pull slack out and drive through legs through the extended range.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-snatch-grip-deadlift',
      name: 'Snatch-Grip Deadlift',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set feet in deadlift stance and take an ultra-wide snatch collar grip.
2. Drop hips lower to compensate for the wide grip.
3. Pull powerfully focusing on upper back, traps, and lat engagement.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-pull-up',
      name: 'Pull Up (Overhand)',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Grip overhead bar with overhand grip wider than shoulders.
2. Hang with arms straight, depress and retract scapulae.
3. Pull chest up toward bar driving elbows down and back.
4. Lower with control to a dead hang.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-chin-up',
      name: 'Chin Up (Underhand)',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip bar with underhand grip shoulder-width apart.
2. Pull elbows down toward ribs until chin clears bar.
3. Squeeze lats and biceps hard at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-neutral-pull-up',
      name: 'Neutral Grip Pull Up',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grasp parallel handles with palms facing each other.
2. Pull body upward leading with chest until chin passes handles.
3. Lower with control to full arm stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-wide-pull-up',
      name: 'Wide-Grip Pull Up',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Take wide overhand grip on pull-up bar.
2. Drive elbows straight down toward hips without swinging.
3. Focus strictly on outer lat flare and upper back contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-behind-neck-pull-up',
      name: 'Behind the Neck Pull Up',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip wide and pull until bar touches back of neck.
2. Keep core engaged and do not excessively jut head forward.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-assisted-pull-up',
      name: 'Assisted Pull Up Machine',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Select counterbalance weight pad and kneel on platform.
2. Grip overhead handles and pull chest upward under controlled tempo.
3. Lower smoothly to full overhead stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-bb-row',
      name: 'Barbell Bent Over Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hinge at hips until torso is ~45° to floor with neutral spine.
2. Pull barbell toward lower ribcage / belly button.
3. Squeeze shoulder blades together at top, lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-pendlay-row',
      name: 'Pendlay Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Torso parallel to floor with bar resting on ground each rep.
2. Explosively row barbell to sternum without raising hips.
3. Return bar completely to dead stop on floor before next rep.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-yates-row',
      name: 'Yates Row (Underhand Barbell Row)',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Grip barbell with underhand grip, torso at ~70° incline.
2. Pull bar smoothly into lower waist/belly button.
3. Squeeze lower lats and mid-back firmly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-seal-row',
      name: 'Barbell Seal Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie face down on an elevated horizontal bench.
2. Grasp barbell from floor with overhand grip.
3. Row bar up to touch bench bottom without body english.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-t-bar-row',
      name: 'T-Bar Row (Chest Supported)',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie face down on pad with chest firmly supported.
2. Grasp handles and pull elbows back past torso.
3. Squeeze mid-back and rhomboids, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-t-bar-landmine',
      name: 'T-Bar Row (Landmine Free Bar)',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Straddle landmine barbell with V-handle hooked under bar.
2. Hinge hips to 45° with flat back.
3. Pull handle to touch abdomen, pause, and lower to full stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-lat-pulldown-wide',
      name: 'Lat Pulldown (Wide Grip)',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with thighs secured under roller pads.
2. Grip bar with wide overhand grip, lean back slightly (~10°).
3. Pull bar to upper chest driving elbows down and back.
4. Return smoothly to full overhead stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-lat-pulldown-close',
      name: 'Lat Pulldown (Close Grip V-Bar)',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Attach V-bar handle to pulldown cable.
2. Pull handle down to upper chest puffing sternum forward.
3. Squeeze lower lats hard, then allow full overhead stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-lat-pulldown-reverse',
      name: 'Lat Pulldown (Underhand Reverse Grip)',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Grip straight bar with underhand grip shoulder-width apart.
2. Pull bar down toward collarbone keeping elbows tucked close.
3. Focus on deep lower lat contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-single-arm-lat-pulldown',
      name: 'Single-Arm Cable Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Kneel or sit sideways at high pulley with single D-handle.
2. Pull handle down while driving elbow directly toward hip.
3. Squeeze lat unilaterally, then control stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-half-kneeling-lat-pulldown',
      name: 'Half-Kneeling Single-Arm Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set the cable pulley high up. Adopt a half-kneeling stance (one knee on the ground, opposite foot planted forward).
2. Grasp the single handle with the arm on the side of the down knee.
3. Pull the cable down and back, driving the elbow tight toward your hip and lower back.
4. Slowly return under control into a full overhead lat stretch, then repeat for the opposite side.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-behind-neck-pulldown',
      name: 'Behind the Neck Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit facing away or toward machine, grasp wide grip bar.
2. Pull bar smoothly down to base of neck keeping torso upright.
3. Slowly return to top without jarring spine.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-lat-pulldown-machine',
      name: 'Leverage Lat Pulldown Machine',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust seat so chest is pressed against pad or thighs locked.
2. Pull independent lever handles downward along machine arc.
3. Squeeze lats hard at bottom, control eccentric ascent.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-seated-cable-row',
      name: 'Seated Cable Row (Close Grip V-Bar)',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on bench with knees slightly bent, feet on footrests.
2. Pull handle toward navel while keeping chest tall.
3. Squeeze shoulder blades together, return to full stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-seated-row-wide',
      name: 'Seated Cable Row (Wide Grip)',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Attach wide lat bar to low cable pulley.
2. Pull bar toward sternum with elbows flared at 60° angle.
3. Squeeze upper back, rear delts, and rhomboids intensely.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-single-arm-cable-row',
      name: 'Single-Arm Seated Cable Row',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit at low pulley holding D-handle with one hand.
2. Pull elbow straight back into side pocket with slight rotation.
3. Deeply stretch forward at start of each repetition.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-one-arm-db-row',
      name: 'One-Arm Dumbbell Row',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place one knee and hand on flat bench, back parallel to floor.
2. Hold dumbbell in free hand, arm hanging straight down.
3. Pull dumbbell up toward hip driving elbow past ribs.
4. Lower under control to full lat stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-chest-supported-row',
      name: 'Chest Supported Dumbbell Row',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set incline bench to 30-45°. Lie prone with chest on pad.
2. Hold dumbbells hanging straight down.
3. Row dumbbells up pulling elbows toward ceiling.
4. Squeeze shoulder blades hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-batwing-row',
      name: 'Dumbbell Batwing Row',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie prone on flat or slight incline bench.
2. Row heavy dumbbells up into armpits, pinning shoulder blades back.
3. Hold peak contraction for 2 solid seconds each rep.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-kroc-row',
      name: 'Kroc Row (Heavy High Rep DB Row)',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand with one hand braced on dumbbell rack, torso bent over.
2. Use heavy dumbbell and allow controlled body english.
3. Row explosively into ribcage for high reps (15-25).''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-meadows-row',
      name: 'Meadows Row (Landmine Single Arm)',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand perpendicular to landmine barbell, hip-hinged with staggered feet.
2. Overhand grip the thick barbell collar.
3. Row elbow up and back focusing on lower lat sweep.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-bb-shrug',
      name: 'Barbell Shrug',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold barbell with overhand grip in front of thighs.
2. Shrug shoulders straight up toward ears as high as possible.
3. Hold for 1 second, lower smoothly without rolling shoulders.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-db-shrug',
      name: 'Dumbbell Shrug',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand holding dumbbells at sides with neutral grip.
2. Elevate shoulders straight up toward ears in pure vertical path.
3. Squeeze upper traps hard at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-smith-shrug',
      name: 'Smith Machine Shrug',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set Smith bar at mid-thigh height with overhand grip.
2. Shrug shoulders vertically along fixed track.
3. Hold top squeeze, then lower with full stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-cable-shrug',
      name: 'Cable Shrug',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand between dual low cable pulleys holding handles.
2. Shrug shoulders upward and slightly inward along line of cable pull.
3. Control the descent against constant cable tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-behind-back-shrug',
      name: 'Behind the Back Barbell Shrug',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold barbell behind glutes with overhand grip.
2. Shrug shoulders upward and slightly back.
3. Squeeze traps and upper neck musculature.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-straight-arm-pulldown',
      name: 'Straight Arm Cable Pushdown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand facing high pulley with straight bar or rope.
2. Keep arms nearly straight with slight elbow bend.
3. Sweep bar down in an arc to thighs using lats.
4. Squeeze lats hard at bottom, control ascent to eye level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-db-pullover-lat',
      name: 'Dumbbell Pullover (Lat Biased)',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on flat bench holding dumbbell overhead with palms cupping weight.
2. Lower dumbbell back past head with slight elbow bend.
3. Pull weight back up to forehead level focusing purely on lat pull.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-face-pull',
      name: 'Face Pull',
      muscleGroup: 'Back',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set pulley at eye level with rope attachment.
2. Grasp rope with thumbs back, pull toward bridge of nose.
3. Separate hands and externally rotate shoulders at peak contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-prone-y-raise',
      name: 'Incline Prone Y-Raise (Lower Traps)',
      muscleGroup: 'Back',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie chest-down on 30° incline bench holding light dumbbells.
2. Raise arms upward and outward in a "Y" shape with thumbs pointing up.
3. Squeeze lower traps and hold top for 1 second.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-hyperextensions',
      name: 'Back Extension / Hyperextension',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Position hips on 45° back extension pad with ankles hooked.
2. Cross arms on chest and bend forward at waist.
3. Raise torso until body forms straight line squeezing erectors and glutes.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-weighted-hyperextension',
      name: 'Weighted Hyperextensions',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hook into 45° bench holding weight plate or dumbbell against chest.
2. Lower torso smoothly, then extend up to neutral alignment.
3. Keep spinal erectors under constant controlled tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-machine-back-extension',
      name: 'Machine Back Extension',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with pad resting against upper back.
2. Push back smoothly extending spine against resistance.
3. Pause at upright lockout, then control return forward.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-good-morning',
      name: 'Good Morning',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Place barbell across upper back/traps in squat stance.
2. Hinge at hips pushing butt back with soft knees.
3. Lower torso until parallel to floor while keeping flat back.
4. Drive hips forward back to standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-rack-pull',
      name: 'Rack Pull',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set barbell on safety pins just below or at knee height.
2. Grip bar with overhand or mixed grip, brace lats and core.
3. Drive hips forward into bar to lock out with powerful glute squeeze.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-machine-low-row',
      name: 'Machine Low Row (Plate Loaded)',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit facing machine with chest pressed into pad.
2. Grasp handles and pull elbows back toward waist.
3. Squeeze lower and mid lats, resist on return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-machine-high-row',
      name: 'Machine High Row (Plate Loaded)',
      muscleGroup: 'Back',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with knees locked under rollers.
2. Pull high angled handles down and back toward ribs.
3. Squeeze lat flare and lower mid-back.''',
      isCustom: false,
    ),
    Exercise(
      id: 'back-inverted-row',
      name: 'Inverted Row (Bodyweight Australian Row)',
      muscleGroup: 'Back',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hang under a Smith bar or barbell in a rack with heels on floor.
2. Keep body in rigid reverse plank position.
3. Pull chest up to touch bar, squeezing shoulder blades together.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-overhead-bb-press',
      name: 'Overhead Barbell Press (OHP)',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand feet shoulder-width, bar resting on front delts/clavicle.
2. Brace core and glutes, tilt head slightly back.
3. Press bar vertically overhead, moving head forward under bar at lockout.
4. Lower with control back to clavicle.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-push-press',
      name: 'Push Press (Barbell)',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rack bar across front delts. Dip knees 3-4 inches in vertical dip.
2. Drive upward explosively through legs to propel bar off shoulders.
3. Press out overhead into full stable lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-seated-bb-press',
      name: 'Seated Overhead Barbell Press',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on upright bench with bar racked overhead or unrack from chest.
2. Press bar straight up overhead to arm lockout.
3. Lower with control to collarbone level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-behind-neck-press',
      name: 'Seated Behind the Neck Press',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit with upright posture, bar resting on upper traps.
2. Press barbell vertically until arms are extended.
3. Lower under strict control to ears/nape of neck.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-standing-behind-neck-press',
      name: 'Standing Behind the Neck Press',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand tall with bar on upper traps in snatch or wide grip.
2. Press bar straight up overhead keeping torso rigid.
3. Lower carefully to upper traps under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-seated-db-press',
      name: 'Seated Dumbbell Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit on 90° bench, kick dumbbells to shoulder height.
2. Press dumbbells overhead in slight arc until arms are extended.
3. Lower with control until dumbbells are level with ears.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-standing-db-press',
      name: 'Standing Dumbbell Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand with core braced, dumbbells held at shoulder level.
2. Press dumbbells overhead avoiding excessive lower back arching.
3. Lower smoothly to shoulder level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-arnold-press',
      name: 'Arnold Dumbbell Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold dumbbells at chest palms facing you (like top of curl).
2. As you press overhead, rotate wrists outward so palms face forward.
3. Reverse rotation on descent back to starting position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-machine-shoulder-press',
      name: 'Machine Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Adjust seat so handles are at ear level.
2. Press handles overhead along track until arms extend.
3. Lower slowly resisting weight stack.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-smith-shoulder-press',
      name: 'Smith Machine Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position 85° bench under Smith bar.
2. Unhook bar and lower in front of chin/upper chest.
3. Press up overhead along guided path.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-db-lateral-raise',
      name: 'Dumbbell Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand with dumbbells at sides with slight forward torso lean.
2. Raise arms out to sides leading with elbows until parallel with floor.
3. Pour slightly outward at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-seated-lateral-raise',
      name: 'Seated Dumbbell Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit on bench with dumbbells hanging at sides.
2. Lift weights out to sides eliminating all leg momentum.
3. Pause for split second at shoulder height, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-lateral-raise',
      name: 'Cable Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set low pulley behind back or front, hold D-handle.
2. Raise arm outward and upward to shoulder height.
3. Control descent against continuous cable tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-lateral-behind',
      name: 'Cable Lateral Raise (Behind the Back)',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand sideways to low cable, handle running behind glutes.
2. Raise arm out laterally feeling continuous side delt load.
3. Lower with steady 2-second eccentric.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-leaning-lateral-raise',
      name: 'Leaning Cable Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold pole with one hand, lean body outward at 30° angle.
2. Hold low cable with outer hand and raise laterally.
3. Peak tension occurs at side delt contraction point.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cross-body-cable-lateral',
      name: 'Cross-Body Cable Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set dual low cables. Cross arms to grab opposite handles.
2. Raise both arms out to sides simultaneously in wide sweeping motion.
3. Squeeze lateral delts at shoulder level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-machine-lateral-raise',
      name: 'Machine Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust seat so machine pivot aligns with shoulder joint.
2. Place upper arms/elbows against pads.
3. Raise arms outward to shoulder height, hold, and lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-front-db-raise',
      name: 'Dumbbell Front Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold dumbbells in front of thighs with overhand grip.
2. Raise one or both dumbbells straight forward to eye level.
3. Lower slowly without swinging torso.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-bb-front-raise',
      name: 'Barbell Front Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold barbell with shoulder-width overhand grip.
2. Lift barbell forward in an arc to shoulder level.
3. Lower under strict control feeling anterior delt burn.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-front-raise',
      name: 'Cable Front Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Straddle low cable pulley with rope or straight bar between legs.
2. Raise arms straight forward to eye level against cable resistance.
3. Lower slowly to thighs.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-plate-front-raise',
      name: 'Plate Front Raise',
      muscleGroup: 'Shoulders',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold weight plate at 3 and 9 o'clock positions.
2. Raise plate up to eye level keeping arms straight.
3. Lower smoothly back to waist.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-reverse-pec-deck',
      name: 'Reverse Pec Deck (Rear Delt Fly)',
      muscleGroup: 'Shoulders',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit facing pad, adjust seat so handles are at shoulder level.
2. Grasp handles and push arms outward and backward in horizontal arc.
3. Squeeze rear delts at peak, control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-db-rear-delt-fly',
      name: 'Bent Over Rear Delt Dumbbell Fly',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hinge at hips until torso is parallel to floor.
2. With elbows slightly bent, raise dumbbells out to sides.
3. Squeeze back of shoulders at top, lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-incline-rear-delt-fly',
      name: 'Incline Bench Rear Delt Dumbbell Fly',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie face down on 30° incline bench.
2. Let arms hang down, then sweep dumbbells out wide.
3. Eliminate lower back involvement for pure rear delt work.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-rear-delt-fly',
      name: 'Cable Rear Delt Fly (High Cross)',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set dual pulleys at head height without attachments.
2. Grab left cable with right hand, right cable with left hand.
3. Pull arms outward and back horizontally squeezing rear delts.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-single-cable-rear-delt',
      name: 'Single-Arm Cable Rear Delt Fly',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand sideways to cable at shoulder height.
2. Reach across body and pull cable horizontally outward.
3. Squeeze posterior delt without rotating torso.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-upright-row-bb',
      name: 'Barbell Upright Row',
      muscleGroup: 'Shoulders',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold barbell with overhand grip wider than shoulder-width.
2. Pull barbell up along body until elbows reach shoulder height.
3. Lower bar smoothly under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-upright-row-db',
      name: 'Dumbbell Upright Row',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold dumbbells in front of thighs.
2. Pull dumbbells vertically along torso leading with high elbows.
3. Squeeze side delts at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-upright-row-cable',
      name: 'Cable Upright Row',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Attach straight bar to low cable pulley.
2. Pull bar upward toward clavicle leading with elbows.
3. Maintain constant cable resistance throughout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-smith-upright-row',
      name: 'Smith Machine Upright Row',
      muscleGroup: 'Shoulders',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Unrack Smith bar with wide overhand grip.
2. Pull bar vertically along guided rails to mid-chest.
3. Lower with smooth eccentric control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-lu-raises',
      name: 'Lu Raises (Olympic Style Lateral Raise)',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold light dumbbells at sides with knuckles facing out.
2. Raise dumbbells in a complete 180° arc until they touch overhead.
3. Lower under control through full shoulder range.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-external-rotation',
      name: 'Cable External Rotation (Rotator Cuff)',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set pulley at elbow height, hold handle with elbow bent at 90° against ribs.
2. Rotate forearm outward away from body without moving elbow.
3. Control back inward to strengthen infraspinatus.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cable-internal-rotation',
      name: 'Cable Internal Rotation (Rotator Cuff)',
      muscleGroup: 'Shoulders',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set pulley at elbow height, hold handle with elbow at 90° against ribs.
2. Rotate forearm inward across stomach.
3. Return smoothly under control to train subscapularis.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-cuban-press',
      name: 'Cuban Press (Dumbbell)',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Upright row dumbbells until upper arms are parallel to floor.
2. Externally rotate forearms up into an overhead position.
3. Press dumbbells overhead, then reverse sequence.''',
      isCustom: false,
    ),
    Exercise(
      id: 'sh-db-scaption',
      name: 'Dumbbell Scaption',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand holding light dumbbells with thumbs pointing up.
2. Raise arms in scapular plane (30° forward of pure lateral).
3. Lift to shoulder height and lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-bb-curl',
      name: 'Barbell Bicep Curl',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand with shoulder-width underhand grip on barbell.
2. Keep elbows pinned to sides, curl bar toward shoulders.
3. Squeeze biceps hard at top without swinging hips.
4. Lower bar under control to full extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-ez-curl',
      name: 'EZ-Bar Bicep Curl',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip angled sections of EZ-bar with underhand grip.
2. Curl bar smoothly toward upper chest keeping elbows tucked.
3. Squeeze peaks, lower with 2-second eccentric tempo.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-db-curl',
      name: 'Dumbbell Bicep Curl (Standing)',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand holding dumbbells at sides palms facing thighs.
2. Curl dumbbells up, supinating wrists (palms up) by mid-rep.
3. Squeeze bicep at top, lower slowly with full control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-seated-db-curl',
      name: 'Seated Dumbbell Bicep Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit upright on flat bench holding dumbbells at sides.
2. Curl dumbbells up with supination, keeping elbows fixed.
3. Lower slowly feeling deep bicep stretch at bottom.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-incline-db-curl',
      name: 'Incline Dumbbell Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set bench to 45-60° angle. Lie back letting arms hang down.
2. Curl dumbbells up without allowing elbows to swing forward.
3. Squeeze at top, lower under deep long-head bicep stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-hammer-curl',
      name: 'Dumbbell Hammer Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand holding dumbbells with neutral grip (palms facing inward).
2. Curl dumbbells up keeping palms facing each other throughout.
3. Squeeze brachialis and forearm at top, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-cross-body-hammer',
      name: 'Cross-Body Hammer Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold dumbbell with neutral grip.
2. Curl dumbbell across chest toward opposite shoulder.
3. Squeeze brachialis and outer bicep head, lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-preacher-curl',
      name: 'Preacher Curl (EZ-Bar)',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest armpits over top of preacher bench, triceps flat on pad.
2. Grip EZ-bar with underhand grip, curl upward toward chin.
3. Squeeze biceps, lower with control stopping just short of hyperextension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-db-preacher',
      name: 'Preacher Curl (Dumbbell)',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Rest arm over preacher bench pad holding dumbbell.
2. Curl dumbbell up toward shoulder without lifting elbow.
3. Squeeze bicep peak, lower smoothly to bottom stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-machine-preacher',
      name: 'Machine Preacher Curl',
      muscleGroup: 'Biceps',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Adjust seat so armpits align with pad edge.
2. Grip handles and curl upward against constant machine resistance.
3. Hold contraction for 1 second, control eccentric lowering.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-concentration-curl',
      name: 'Concentration Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit on bench, brace tricep against inner thigh.
2. Curl dumbbell up toward face without rocking torso.
3. Squeeze bicep peak hard at top, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-cable-curl',
      name: 'Cable Bicep Curl (Straight Bar)',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach straight bar to low pulley, stand tall with elbows tucked.
2. Curl bar up toward chin under constant cable tension.
3. Squeeze biceps at peak, control descent.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-cable-hammer-rope',
      name: 'Cable Rope Hammer Curl',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach rope to low pulley, hold with neutral hammer grip.
2. Curl rope up, spreading handles apart at top for maximum contraction.
3. Lower with control back to starting stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-high-cable-curl',
      name: 'High Cable Bicep Curl (Double Arm)',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand between dual high pulleys holding handles with arms out in T-pose.
2. Curl handles inward toward ears simultaneously.
3. Squeeze bicep peaks intensely, then control return to straight arms.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-bayesian-curl',
      name: 'Bayesian Cable Curl',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand facing away from low cable, holding D-handle behind torso.
2. Curl arm forward allowing shoulder to flex slightly at peak.
3. Squeeze bicep, return arm behind torso for deep stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-spider-curl',
      name: 'Spider Curl (Barbell)',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie face down on 45° incline bench with arms hanging vertically.
2. Curl barbell up toward forehead without letting elbows drift back.
3. Squeeze bicep short head hard at peak contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-spider-curl-db',
      name: 'Spider Curl (Dumbbell)',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie prone on incline bench, arms hanging straight down.
2. Curl dumbbells upward focusing on strict bicep contraction.
3. Lower slowly without swinging weights.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-waiter-curl',
      name: 'Waiter Curl (Dumbbell)',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand holding one dumbbell vertically with both palms under top plate.
2. Curl dumbbell up keeping plate flat like a waiter carrying a tray.
3. Squeeze bicep peaks hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-drag-curl',
      name: 'Drag Curl (Barbell)',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand holding barbell, pull elbows backward behind torso.
2. Drag bar straight up along torso toward lower chest.
3. Squeeze biceps tightly without anterior shoulder involvement.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-drag-curl-smith',
      name: 'Drag Curl (Smith Machine)',
      muscleGroup: 'Biceps',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand inside Smith machine with bar resting against thighs.
2. Pull elbows back as you drag bar vertically along chest line.
3. Squeeze bicep peaks hard at the top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-21s',
      name: '21s Bicep Curl (Barbell)',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Perform 7 bottom-half reps (thighs to parallel).
2. Perform 7 top-half reps (parallel to chest).
3. Perform 7 full-range reps without rest.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-zottman-curl',
      name: 'Zottman Curl',
      muscleGroup: 'Biceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Curl dumbbells up with palms facing up (supinated).
2. At the top, rotate wrists so palms face down (pronated).
3. Lower dumbbells slowly with pronated grip to train forearms and brachialis.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-cheat-curls',
      name: 'Cheat Curls (Heavy Barbell)',
      muscleGroup: 'Biceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Load barbell heavier than normal curling weight.
2. Use controlled hip hinge momentum to power bar up.
3. Lower bar with strict 3-4 second negative under deep tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-reverse-cable-curl',
      name: 'Reverse Grip Cable Curl',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach straight bar to low pulley with overhand (palms down) grip.
2. Curl bar up toward chest keeping elbows fixed.
3. Squeeze brachioradialis and biceps at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'biceps-single-cable-preacher',
      name: 'Single-Arm Cable Preacher Curl',
      muscleGroup: 'Biceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set preacher bench in front of low cable with D-handle.
2. Curl handle up smoothly with constant cable tension throughout range.
3. Squeeze bicep peak, lower with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-rope-pushdown',
      name: 'Cable Tricep Rope Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand facing high pulley holding rope attachment.
2. Pin elbows to sides, press down extending arms fully.
3. Spread rope tips apart at bottom for peak tricep contraction.
4. Return with control to 90° elbow bend.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-bar-pushdown',
      name: 'Straight Bar Tricep Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip straight bar with overhand grip on high cable.
2. Push bar down until elbows lock out fully.
3. Squeeze triceps hard, allow bar to return smoothly to chest level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-vbar-pushdown',
      name: 'V-Bar Tricep Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Attach V-bar to high cable pulley.
2. Push downward driving weight through outer palms.
3. Lock out triceps at bottom, resist on the eccentric return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-single-arm-cable',
      name: 'Single-Arm Cable Tricep Extension',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand sideways to high pulley holding D-handle or ball.
2. Extend arm straight down focusing purely on unilateral tricep contraction.
3. Control the negative back up to ear level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-reverse-pushdown',
      name: 'Reverse Grip Cable Tricep Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach straight bar to high cable with underhand (palms up) grip.
2. Pull bar down locking elbows into side, extending forearms down.
3. Squeeze medial tricep head hard at lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-skull-crushers',
      name: 'Skull Crusher (Lying EZ-Bar Extension)',
      muscleGroup: 'Triceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on flat bench holding EZ-bar with arms extended over chest.
2. Angle upper arms back slightly (~10-15°).
3. Bend elbows lowering bar toward forehead/crown of head.
4. Extend elbows powerfully back to starting position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-db-skull-crusher',
      name: 'Lying Dumbbell Tricep Extension',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on flat bench holding dumbbells with neutral grip overhead.
2. Bend elbows lowering dumbbells beside temples.
3. Extend arms upward contracting triceps hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-overhead-db-ext',
      name: 'Overhead Dumbbell Tricep Extension',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on bench holding single heavy dumbbell overhead with both palms cupping weight.
2. Lower dumbbell behind head bending elbows to 90° or deeper.
3. Extend arms straight up overhead squeezing tricep long heads.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-single-arm-overhead-db',
      name: 'Single-Arm Overhead Dumbbell Extension',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit tall holding dumbbell vertically overhead with one arm.
2. Lower dumbbell behind head feeling deep stretch in tricep long head.
3. Press dumbbell back up to full arm extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-overhead-cable-ext',
      name: 'Overhead Cable Rope Extension',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set cable to mid/high position, face away with rope behind neck.
2. Lean forward into split stance with stable core.
3. Extend arms forward and upward spreading rope at lockout.
4. Return under control feeling long-head tricep stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-katana-extension',
      name: 'Katana Cable Tricep Extension',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set dual high cables. Cross arms to grab opposite cables behind neck.
2. Extend arms diagonally outward like drawing twin swords.
3. Peak contraction lines up perfectly with tricep long heads.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-close-grip-bench',
      name: 'Close-Grip Barbell Bench Press',
      muscleGroup: 'Triceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on bench with grip shoulder-width apart (not excessively narrow).
2. Lower bar to lower chest keeping elbows tucked tight to ribs.
3. Drive bar up powerfully emphasizing tricep lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-jm-press-bb',
      name: 'JM Press (Barbell)',
      muscleGroup: 'Triceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on flat bench with close grip on barbell.
2. Lower bar toward neck/upper chest in a hybrid press and skull crusher.
3. Keep elbows forward, pause briefly, and press up with triceps.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-jm-press-smith',
      name: 'JM Press (Smith Machine)',
      muscleGroup: 'Triceps',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position bench under Smith machine bar.
2. Lower bar down toward throat/chin with elbows pointing forward.
3. Drive weight up purely using tricep extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-tate-press',
      name: 'Tate Press (Dumbbell)',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on flat bench holding dumbbells on chest with palms facing feet.
2. Bend elbows out to sides lowering bells to lightly touch sternum.
3. Extend arms upward locking out triceps.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-dips-parallel',
      name: 'Tricep Dips (Parallel Bars)',
      muscleGroup: 'Triceps',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Mount parallel bars keeping torso completely upright.
2. Keep elbows tucked close to sides (not flared).
3. Lower until elbows reach 90° bend.
4. Push up forcefully to full arm extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-weighted-dips',
      name: 'Weighted Tricep Dips',
      muscleGroup: 'Triceps',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach weight belt with plate or dumbbell between ankles.
2. Keep torso vertical to bias triceps over chest.
3. Lower to 90° elbow depth and drive to crisp lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-bench-dips',
      name: 'Bench Dips',
      muscleGroup: 'Triceps',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Place hands on edge of bench, legs extended forward.
2. Lower hips toward floor keeping back close to bench.
3. Press through palms to extend elbows fully.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-machine-dip',
      name: 'Machine Tricep Dip',
      muscleGroup: 'Triceps',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with handles at waist height.
2. Push handles down extending arms fully.
3. Squeeze triceps at bottom, resist weight on return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-machine-extension',
      name: 'Machine Tricep Extension (Seated)',
      muscleGroup: 'Triceps',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust seat so elbows align with machine axis of rotation.
2. Rest back of arms on pad and push handles forward to extension.
3. Hold contraction, then lower under steady control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-kickback-db',
      name: 'Dumbbell Tricep Kickback',
      muscleGroup: 'Triceps',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hinge at hips with torso parallel to floor, upper arm pinned to ribs.
2. Extend forearm backward until arm is completely straight.
3. Squeeze tricep hard at top, lower forearm to 90°.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-kickback-cable',
      name: 'Cable Tricep Kickback',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set low pulley without handle, grab rubber stopper.
2. Hinge forward, pin upper arm to ribcage.
3. Extend arm backward against constant cable resistance.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-diamond-pushup',
      name: 'Diamond Push Up (Tricep Focus)',
      muscleGroup: 'Triceps',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Plank stance with hands forming diamond directly under chest.
2. Keep elbows tucked close to sides as you lower body.
3. Press through palms emphasizing tricep lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-floor-skull-crusher',
      name: 'Floor Skull Crusher (Barbell)',
      muscleGroup: 'Triceps',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on floor holding barbell above chest.
2. Bend elbows lowering bar until plates touch floor behind head.
3. Pause to kill momentum, then extend triceps powerfully.''',
      isCustom: false,
    ),
    Exercise(
      id: 'triceps-single-overhead-cable',
      name: 'Single-Arm Overhead Cable Tricep Extension',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set low/mid pulley and face away holding single handle behind neck.
2. Extend arm overhead along natural diagonal plane.
3. Squeeze tricep long head, lower under deep controlled stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-wrist-curl-bb',
      name: 'Barbell Wrist Curl (Palms Up)',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest forearms on bench with wrists hanging over edge, palms facing up.
2. Lower barbell letting it roll down onto finger pads.
3. Curl fingers and flex wrists upward as high as possible.
4. Squeeze forearm flexors tightly at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-reverse-wrist-curl',
      name: 'Barbell Reverse Wrist Curl (Palms Down)',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest forearms on bench palms facing down, wrists over edge.
2. Lower barbell letting wrists flex downward.
3. Extend wrists upward lifting barbell with forearm extensors.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-db-wrist-curl',
      name: 'Dumbbell Wrist Curl',
      muscleGroup: 'Forearms',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Rest forearm on thigh or bench with palm facing up.
2. Lower dumbbell letting it roll down to finger tips.
3. Curl dumbbell back up flexing wrist hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-db-reverse-wrist',
      name: 'Dumbbell Reverse Wrist Curl',
      muscleGroup: 'Forearms',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Rest forearm on thigh with palm facing down.
2. Lower dumbbell, then extend wrist upward toward ceiling.
3. Squeeze forearm extensors at peak contraction.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-reverse-bb-curl',
      name: 'Reverse Barbell Curl',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Grip barbell with overhand (pronated) shoulder-width grip.
2. Keep elbows tucked, curl bar up toward upper chest.
3. Squeeze brachioradialis and forearm extensors hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-reverse-ez-curl',
      name: 'Reverse EZ-Bar Curl',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip outer angled bends of EZ-bar with overhand grip.
2. Curl bar up smoothly maintaining strict wrist position.
3. Lower with 2-second eccentric for forearm hypertrophy.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-reverse-cable-curl',
      name: 'Reverse Cable Curl',
      muscleGroup: 'Forearms',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Attach straight bar to low pulley with overhand grip.
2. Curl bar up against continuous cable tension.
3. Squeeze outer forearms and brachioradialis.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-behind-back-wrist-curl',
      name: 'Behind the Back Barbell Wrist Curl',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand holding barbell behind thighs with palms facing away.
2. Roll bar down onto fingers, then curl fingers and wrists upward.
3. Squeeze inner forearm flexors.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-plate-pinch',
      name: 'Plate Pinch Hold',
      muscleGroup: 'Forearms',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place two smooth weight plates together with smooth sides facing out.
2. Pinch plates between thumb and fingers.
3. Stand tall and hold for maximum time to build crushing pinch grip.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-dead-hang',
      name: 'Dead Hang',
      muscleGroup: 'Forearms',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip pull-up bar with overhand shoulder-width grip.
2. Hang freely with arms straight and feet off floor.
3. Hold for time to build immense grip endurance and decompress spine.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-active-hang',
      name: 'Active Shoulder Hang',
      muscleGroup: 'Forearms',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hang from pull-up bar with overhand grip.
2. Engage scapular depressors and grip to pull shoulders away from ears.
3. Hold with active tension in forearms, lats, and upper back.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-wrist-roller',
      name: 'Wrist Roller (Weighted)',
      muscleGroup: 'Forearms',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold wrist roller handle with arms outstretched in front of chest.
2. Roll rope up by alternating wrist extensions until weight reaches top.
3. Slowly unroll back down under complete eccentric control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-farmers-carry-db',
      name: 'Farmer\'s Carry / Walk (Heavy Dumbbells)',
      muscleGroup: 'Forearms',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Pick up heavy pair of dumbbells with neutral grip.
2. Walk with short, measured steps keeping shoulders back and core tight.
3. Walk for distance or time to build forearms, traps, and core.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-trap-bar-carry',
      name: 'Trap Bar Farmer\'s Carry',
      muscleGroup: 'Forearms',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand inside heavily loaded trap bar and lift to standing.
2. Walk forward with upright posture and braced core.
3. Hold for distance to overload grip capacity.''',
      isCustom: false,
    ),
    Exercise(
      id: 'forearms-towel-pullup',
      name: 'Towel Grip Pull Up',
      muscleGroup: 'Forearms',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Drape two towels over pull-up bar.
2. Grip towel ends tightly and perform pull-ups.
3. Challenges grip, forearms, and finger strength to the limit.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bb-back-squat',
      name: 'Barbell Back Squat',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Bar across upper traps, feet shoulder-width, toes slightly flared.
2. Inhale deep into belly, brace core, break at hips and knees.
3. Squat down until hips drop below knee crease (parallel or below).
4. Drive up powerfully through midfoot to full hip extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bb-low-bar-squat',
      name: 'Barbell Low Bar Squat',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest bar across rear delts, take slightly wider stance with forward torso lean.
2. Sit back into hips and squat to parallel.
3. Drive hips up out of hole utilizing strong posterior chain.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bb-front-squat',
      name: 'Barbell Front Squat',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest bar on front delts in clean grip or cross-arm grip with elbows high.
2. Keep torso completely upright and squat deep into knee flexion.
3. Drive through midfoot maintaining elevated elbows.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-zercher-squat',
      name: 'Zercher Squat',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Cradle barbell in crooks of elbows against chest with clasped hands.
2. Squat down between knees keeping torso vertical.
3. Drive back up working quads, upper back, and core.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-ssb-squat',
      name: 'Safety Squat Bar (SSB) Squat',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Mount SSB on shoulders and hold forward handles.
2. Squat down with upright posture as the camber shifts load forward onto quads.
3. Drive up through heels to standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-box-squat',
      name: 'Box Squat (Barbell)',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set box at parallel or below behind you in squat rack.
2. Squat back onto box, pause for 1 second without rocking or relaxing core.
3. Drive up explosively off box to lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-anderson-squat',
      name: 'Anderson Squat (Pin Squat)',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set safety pins in rack at bottom of squat depth.
2. Position under bar from a dead stop in bottom position.
3. Drive upward from zero momentum to build starting strength.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-hack-squat',
      name: 'Hack Squat (Machine)',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place shoulders under pads, back flat against backrest.
2. Position feet shoulder-width on platform.
3. Release safeties and squat deep into knee flexion.
4. Drive through midfoot extending knees.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-reverse-hack-squat',
      name: 'Reverse Hack Squat',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Face backward toward pad with shoulders under cushions.
2. Squat deep feeling incredible quad and glute loading.
3. Drive up along sled track to full standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-leg-press',
      name: 'Leg Press (45° Sled)',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit in machine with back firmly against pad, feet shoulder-width on sled.
2. Release safeties and lower sled until knees reach 90° without lifting lower back.
3. Press sled up without locking knees out aggressively.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-horizontal-leg-press',
      name: 'Horizontal Leg Press (Machine)',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in seated leg press with feet flat on footplate.
2. Press platform away extending knees.
3. Lower weight under controlled eccentric tempo.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-single-leg-press',
      name: 'Single-Leg Leg Press',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position one foot in center of leg press platform.
2. Lower sled smoothly to 90° angle.
3. Drive through midfoot unilaterally correcting strength imbalances.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-goblet-squat',
      name: 'Goblet Squat (Dumbbell)',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold dumbbell vertically against chest cupping top plate with both palms.
2. Squat down between knees with elbows tracking inside knees.
3. Drive up through midfoot keeping chest proud.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-goblet-squat-kb',
      name: 'Goblet Squat (Kettlebell)',
      muscleGroup: 'Quads',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold kettlebell by horns against chest.
2. Squat deep into the hole keeping chest tall.
3. Stand up powerfully driving hips forward.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bulgarian-split-squat',
      name: 'Bulgarian Split Squat (Dumbbell)',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand 2-3 feet in front of bench. Rest laces of rear foot on bench.
2. Hold dumbbells at sides, lower back knee toward floor.
3. Keep front shin relatively vertical for quad/glute work.
4. Drive through front heel to return to top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bulgarian-split-bb',
      name: 'Bulgarian Split Squat (Barbell)',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place barbell across upper back with rear foot elevated on bench.
2. Descend smoothly until back knee is just above floor.
3. Drive up through front leg maintaining balanced posture.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-walking-lunges',
      name: 'Dumbbell Walking Lunges',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold dumbbells at sides and step forward with long stride.
2. Lower back knee until it gently kisses floor.
3. Push through front heel to step directly into next stride.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-bb-walking-lunges',
      name: 'Barbell Walking Lunges',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold barbell across upper back.
2. Step forward lunging deep with controlled core balance.
3. Drive up into next walking step smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-reverse-lunges-db',
      name: 'Reverse Lunges (Dumbbell)',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand tall with dumbbells at sides.
2. Step one foot backward and drop knee toward floor.
3. Push through front heel to return to standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-reverse-lunges',
      name: 'Barbell Reverse Lunges',
      muscleGroup: 'Quads',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Barbell across upper back. Step one leg backward.
2. Drop back knee toward ground maintaining upright torso.
3. Drive through front leg back to standing position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-forward-lunges-db',
      name: 'Forward Lunges (Dumbbell)',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand tall holding dumbbells, step forward into lunge.
2. Decelerate momentum and lower rear knee to floor.
3. Push off front foot back to starting position.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-leg-extension',
      name: 'Leg Extension Machine',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust back pad so knees align with machine pivot point.
2. Place shins under lower roller pad.
3. Extend legs upward until fully straight, squeezing quads at top.
4. Lower with 2-second eccentric control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-single-leg-extension',
      name: 'Single-Leg Extension Machine',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position one leg under roller pad.
2. Extend leg to full lockout focusing on isolated quad burn.
3. Control the negative descent.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-sissy-squat',
      name: 'Sissy Squat (Bodyweight/Weighted)',
      muscleGroup: 'Quads',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand near support, push knees forward while leaning torso back.
2. Lower until knees are in extreme flexion with quads under massive stretch.
3. Drive through toes back to standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-step-ups',
      name: 'Dumbbell Step-Ups',
      muscleGroup: 'Quads',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand facing 18-24" box holding dumbbells.
2. Place whole front foot on box and step up without pushing off rear toe.
3. Stand tall on box, lower back down under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-smith-squat',
      name: 'Smith Machine Squat',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Position feet slightly in front of bar to bias quads and save lower back.
2. Squat deep into knee flexion.
3. Drive up through heels along fixed vertical track.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-smith-bulgarian',
      name: 'Smith Machine Bulgarian Split Squat',
      muscleGroup: 'Quads',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set bench behind Smith bar and elevate rear foot.
2. Unrack bar and squat down with maximum stability.
3. Drive through front heel to lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-pistol-squat',
      name: 'Pistol Squat (Bodyweight)',
      muscleGroup: 'Quads',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand on one leg, extend other leg straight out in front.
2. Squat down on standing leg until glute touches calf.
3. Drive back up through standing heel to full extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-assisted-pistol',
      name: 'Assisted Pistol Squat',
      muscleGroup: 'Quads',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold TRX straps, pole, or band for balance.
2. Squat deep on one leg with opposite leg extended forward.
3. Use minimal upper body assistance to stand back up.''',
      isCustom: false,
    ),
    Exercise(
      id: 'quads-wall-sit',
      name: 'Wall Sit (Isometric)',
      muscleGroup: 'Quads',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lean back against wall and slide down until thighs are parallel to floor.
2. Knees bent at 90° directly above ankles.
3. Hold position for time feeling quad burn.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-bb-rdl',
      name: 'Romanian Deadlift (Barbell RDL)',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand tall with barbell at hips, overhand grip, feet hip-width.
2. Soften knees and push hips straight backward.
3. Lower bar along shins until you feel deep hamstring stretch.
4. Drive hips forward back to starting lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-db-rdl',
      name: 'Dumbbell Romanian Deadlift',
      muscleGroup: 'Hamstrings',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold dumbbells in front of thighs with neutral or overhand grip.
2. Hinge hips back with slight knee bend keeping spine neutral.
3. Lower dumbbells along shins to mid-shin level.
4. Contract glutes and hamstrings to stand tall.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-single-leg-rdl',
      name: 'Single-Leg Dumbbell RDL',
      muscleGroup: 'Hamstrings',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand on one leg holding dumbbell in opposite hand.
2. Hinge at hips extending free leg straight behind for balance.
3. Lower dumbbell to mid-shin feeling deep hamstring stretch.
4. Pull through standing heel to return to upright.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-stiff-leg-deadlift',
      name: 'Stiff-Legged Deadlift (Barbell SLDL)',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Start with bar on floor, hips positioned higher than normal deadlift.
2. Keep knees almost straight with only micro-bend.
3. Pull bar from floor purely through hamstring and glute extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-lying-leg-curl',
      name: 'Lying Leg Curl (Machine)',
      muscleGroup: 'Hamstrings',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie face down on machine with roller pad behind ankles.
2. Grip side handles and pull heels toward glutes.
3. Hold contraction for 1 second, lower weight smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-seated-leg-curl',
      name: 'Seated Leg Curl (Machine)',
      muscleGroup: 'Hamstrings',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit in machine with thigh pad locked firmly down above knees.
2. Place back of lower calves on roller pad.
3. Curl legs downward and back under seat as far as possible.
4. Slowly return under deep hamstring stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-standing-leg-curl',
      name: 'Standing Single-Leg Curl Machine',
      muscleGroup: 'Hamstrings',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand facing machine pad with roller behind one ankle.
2. Curl heel up toward glute in strict unilateral arc.
3. Squeeze hamstring at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-nordic-curl',
      name: 'Nordic Hamstring Curl',
      muscleGroup: 'Hamstrings',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Kneel on pad with ankles securely anchored under pad or partner.
2. Lower torso forward as slowly as possible resisting with hamstrings.
3. Catch yourself on floor with hands and push back up.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-ghr',
      name: 'Glute-Ham Raise (GHR)',
      muscleGroup: 'Hamstrings',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position knees on pad with feet locked in footplates.
2. Lower torso forward until parallel to floor.
3. Pull through hamstrings and glutes to curl body back upright.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-cable-pull-through',
      name: 'Cable Pull-Through',
      muscleGroup: 'Hamstrings',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Straddle low cable facing away with rope attachment between legs.
2. Hinge at hips letting rope pull hands back through legs.
3. Drive hips forward powerfully to full standing lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-swiss-ball-curl',
      name: 'Swiss Ball Hamstring Curl',
      muscleGroup: 'Hamstrings',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on back with heels on top of Swiss stability ball.
2. Bridge hips up so body forms straight line from heels to shoulders.
3. Roll ball toward glutes by bending knees, then extend back out.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-bb-good-morning',
      name: 'Good Morning (Barbell)',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Rest barbell across upper traps, feet shoulder-width.
2. Hinge at hips pushing glutes back with soft knees.
3. Lower torso until parallel to floor feeling intense hamstring stretch.
4. Drive hips forward to stand.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-ssb-good-morning',
      name: 'Good Morning (Safety Squat Bar)',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Mount SSB bar on shoulders.
2. Hinge deep into hips with neutral flat spine.
3. Drive through hamstrings to return to upright.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-banded-curl',
      name: 'Banded Hamstring Leg Curl',
      muscleGroup: 'Hamstrings',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Anchor resistance band to sturdy post, loop other end around ankles.
2. Lie face down and curl heels toward glutes against band tension.
3. Squeeze hamstrings, return with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-single-lying-curl',
      name: 'Single-Leg Lying Leg Curl',
      muscleGroup: 'Hamstrings',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on machine using one leg against the roller pad.
2. Curl heel toward butt strictly without lifting hips.
3. Excellent for eliminating bilateral strength discrepancies.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-banded-rdl',
      name: 'Romanian Deadlift with Bands',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Loop band around barbell and stand on middle of band.
2. Hinge hips back into RDL.
3. Band tension increases drastically at top lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-deficit-rdl',
      name: 'Deficit Romanian Deadlift',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand on 2-inch platform holding barbell.
2. Hinge hips back lowering bar below shoe level for extended hamstring stretch.
3. Pull hips forward to lockout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-single-kb-rdl',
      name: 'Single-Leg Romanian Deadlift (Kettlebell)',
      muscleGroup: 'Hamstrings',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hold kettlebell in hand opposite working leg.
2. Hinge forward balancing on one leg, back leg extended.
3. Pull through standing heel to return to top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-slider-curl',
      name: 'Slider Hamstring Curl',
      muscleGroup: 'Hamstrings',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on back with heels on sliding discs on smooth floor.
2. Bridge hips up and slide heels toward glutes.
3. Slide back out under control without letting hips touch floor.''',
      isCustom: false,
    ),
    Exercise(
      id: 'hams-bstance-rdl',
      name: 'Barbell B-Stance RDL',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set one foot forward flat, rear foot kicked back on toes for kickstand balance.
2. Hinge hips back loading 90% of weight onto front hamstring.
3. Drive front heel through floor to stand.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-bb-hip-thrust',
      name: 'Barbell Hip Thrust',
      muscleGroup: 'Glutes',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on floor with upper back against bench, padded barbell over hips.
2. Plant feet flat, shoulder-width apart, shins vertical at top.
3. Drive through heels lifting hips until thighs and torso align.
4. Squeeze glutes hard at top for 1 second, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-db-hip-thrust',
      name: 'Dumbbell Hip Thrust',
      muscleGroup: 'Glutes',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Upper back on bench, dumbbell rested across hips.
2. Drive through heels extending hips toward ceiling.
3. Squeeze glutes at peak, lower with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-machine-hip-thrust',
      name: 'Machine Hip Thrust',
      muscleGroup: 'Glutes',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Strap into hip thrust machine pad across hips.
2. Drive through heels against machine lever.
3. Squeeze glutes at full extension, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-kas-glute-bridge',
      name: 'Kas Glute Bridge (Smith Machine)',
      muscleGroup: 'Glutes',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Position upper back on bench under padded Smith bar.
2. Perform small, controlled pulses in top 1/3 range of motion.
3. Pure glute isolation with minimal quad involvement.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-single-leg-thrust',
      name: 'Single-Leg Hip Thrust',
      muscleGroup: 'Glutes',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Rest upper back on bench, raise one foot off floor.
2. Drive through working heel to lift hips to full horizontal.
3. Squeeze glute hard at top, lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-glute-bridge',
      name: 'Barbell Glute Bridge (Floor)',
      muscleGroup: 'Glutes',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie flat on floor with knees bent and padded bar over hips.
2. Drive through heels lifting hips toward ceiling.
3. Squeeze glutes intensely at top, lower to floor.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-cable-kickback',
      name: 'Cable Glute Kickback',
      muscleGroup: 'Glutes',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach ankle cuff to low pulley, face cable machine with slight forward lean.
2. Kick leg backward and slightly outward in an arc.
3. Squeeze glute maximum at peak, control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-machine-kickback',
      name: 'Machine Glute Kickback',
      muscleGroup: 'Glutes',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Place foot against kickback machine pedal.
2. Push leg straight back to full hip extension.
3. Squeeze glute, return smoothly under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-hip-abduction-machine',
      name: 'Seated Hip Abduction Machine',
      muscleGroup: 'Glutes',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with pads on outside of knees.
2. Push knees apart as wide as possible against resistance.
3. Hold peak contraction for 1 second, control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-standing-cable-abduction',
      name: 'Standing Cable Hip Abduction',
      muscleGroup: 'Glutes',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Strap ankle cuff to low cable, stand perpendicular to pulley.
2. Sweep outer leg laterally away from midline.
3. Squeeze gluteus medius at top, lower slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-sumo-squat',
      name: 'Dumbbell Sumo Squat',
      muscleGroup: 'Glutes',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Take wide stance with toes pointed outward at 45°.
2. Hold heavy dumbbell hanging vertically between legs.
3. Squat down deep pushing knees out over toes.
4. Drive through heels and squeeze glutes hard at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-bb-sumo-squat',
      name: 'Barbell Sumo Squat',
      muscleGroup: 'Glutes',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Barbell on back, wide stance with flared toes.
2. Squat deep spreading knees apart over toes.
3. Stand up powerfully driving through heels and glutes.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-frog-pumps',
      name: 'Frog Pumps',
      muscleGroup: 'Glutes',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on back with soles of feet pressed together and knees flared wide.
2. Drive sides of feet into floor lifting hips up.
3. Squeeze glutes hard at top for high reps.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-curtsy-lunge',
      name: 'Dumbbell Curtsy Lunge',
      muscleGroup: 'Glutes',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold dumbbells at sides, step one leg back and across behind other leg.
2. Lower into lunge feeling deep stretch in front gluteus medius.
3. Push through front heel to return to standing.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-cable-pullthrough',
      name: 'Glute Cable Pull-Through',
      muscleGroup: 'Glutes',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Straddle low cable rope facing away.
2. Hinge deeply at hips letting rope pull hands through legs.
3. Snap hips forward into powerful glute squeeze at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-step-up-glute',
      name: 'Glute-Biased High Box Step-Up',
      muscleGroup: 'Glutes',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Use knee-height or higher box, lean torso forward ~45° over front thigh.
2. Drive through whole front foot without pushing off back leg.
3. Extend hip fully on box, step down slowly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-hyperextension-glute',
      name: 'Hyperextension (Rounded Back Glute-Biased)',
      muscleGroup: 'Glutes',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hook into 45° back extension, deliberately round upper back and flare toes outward.
2. Squeeze glutes to pull torso up stopping at neutral alignment.
3. Eliminates back erector dominance to isolate glutes.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-bstance-rdl',
      name: 'B-Stance Romanian Deadlift',
      muscleGroup: 'Glutes',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand with one foot slightly staggered back on toes as kickstand.
2. Hinge hips back loading target glute and hamstring.
3. Drive forward to full hip extension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-lateral-band-walk',
      name: 'Lateral Band Walk',
      muscleGroup: 'Glutes',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Place mini band around ankles or above knees.
2. Assume quarter-squat athletic stance.
3. Take lateral steps keeping tension on band at all times.''',
      isCustom: false,
    ),
    Exercise(
      id: 'glutes-banded-bridge',
      name: 'Glute Bridge with Resistance Band',
      muscleGroup: 'Glutes',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Loop resistance band above knees, lie flat on floor.
2. Push knees outward against band while bridging hips up.
3. Squeeze glutes and abductors at peak height.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-standing-raise',
      name: 'Standing Calf Raise Machine',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place balls of feet on block with shoulders under pads.
2. Lower heels as far as possible feeling deep calf stretch.
3. Drive up onto big toes raising heels as high as possible.
4. Hold peak contraction for 1 second, lower with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-seated-raise',
      name: 'Seated Calf Raise Machine',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine with pad resting across lower thighs.
2. Drop heels below platform for complete soleus stretch.
3. Drive balls of feet through platform into full calf flexion.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-leg-press-raise',
      name: 'Leg Press Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place balls of feet on bottom edge of leg press platform with heels hanging off.
2. Press sled away using ankles and calves.
3. Lower heels slowly into full stretch without bending knees.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-single-leg-raise',
      name: 'Single-Leg Dumbbell Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand on one foot on edge of step holding dumbbell in same-side hand.
2. Lower heel deeply into calf stretch.
3. Drive up onto ball of foot holding top squeeze for 1 second.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-smith-raise',
      name: 'Smith Machine Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Place calf block under Smith bar, rest bar on upper traps.
2. Lower heels below block level.
3. Explode upward onto toes along fixed track.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-donkey-raise',
      name: 'Donkey Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Bend forward at hips with lower back/hips supported under machine pad.
2. Lower heels to full stretch.
3. Raise heels high, squeezing gastrocnemius.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-tibialis-raise',
      name: 'Tibialis Anterior Raise',
      muscleGroup: 'Calves',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand with back against wall, heels 12 inches out.
2. Pull toes up toward shins as high as possible.
3. Hold for 1 second, lower slowly to build front shin strength.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-bodyweight-raise',
      name: 'Bodyweight Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand on edge of stair or block with balls of feet.
2. Lower heels below step for deep stretch, then elevate to full tiptoes.
3. Excellent for high reps and tendon conditioning.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-stair-single-heel-drop',
      name: 'Stair Single-Leg Heel Drop',
      muscleGroup: 'Calves',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand on step on one leg, slowly lower heel over 3-4 seconds.
2. Promotes Achilles tendon health and calf eccentric strength.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-seated-db-raise',
      name: 'Seated Dumbbell Calf Raise',
      muscleGroup: 'Calves',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on bench with balls of feet on block, dumbbells rested on knees.
2. Elevate heels as high as possible against weight.
3. Lower to full stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-rotary-machine',
      name: 'Rotary Calf Machine',
      muscleGroup: 'Calves',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit with feet flat against rotary footplates.
2. Flex ankles forward against machine resistance.
3. Return smoothly feeling complete stretch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'calves-farmers-walk-toes',
      name: 'Farmer\'s Walk on Toes',
      muscleGroup: 'Calves',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1434725039720-aaad6dd32dfe?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold heavy dumbbells at sides and elevate onto tiptoes.
2. Walk forward with short steps while remaining elevated on toes.
3. Demolishes calves with continuous isometric tension.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-hanging-leg-raise',
      name: 'Hanging Leg Raise',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hang from pull-up bar with straight arms and legs together.
2. Posteriorly tilt pelvis, raise legs straight up until parallel or higher.
3. Lower with control avoiding swinging or arching lower back.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-hanging-knee-raise',
      name: 'Hanging Knee Raise',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hang from bar, pull knees up toward chest.
2. Flex spine at top to fully engage rectus abdominis.
3. Lower slowly back to dead hang.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-windshield-wipers',
      name: 'Hanging Windshield Wipers',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hang from pull-up bar, raise toes to bar in inverted L-sit.
2. Rotate legs from side to side in a windshield wiper arc.
3. Squeeze obliques and core on each turn.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-toes-to-bar',
      name: 'Toes to Bar',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hang from pull-up bar with overhand grip.
2. Kip or strictly swing legs upward until toes touch bar between hands.
3. Lower with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-captains-chair-leg',
      name: 'Captain\'s Chair Leg Raise',
      muscleGroup: 'Core',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest forearms on captain's chair pads with back against backrest.
2. Raise straight legs up to 90° angle.
3. Squeeze lower abs, lower smoothly.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-captains-chair-knee',
      name: 'Captain\'s Chair Knee Raise',
      muscleGroup: 'Core',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Support body on captain's chair armrests.
2. Pull knees up tightly into chest curving lower back slightly.
3. Lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-cable-kneeling-crunch',
      name: 'Cable Kneeling Crunch',
      muscleGroup: 'Core',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Kneel facing high pulley holding rope beside ears.
2. Hips stationary, crunch torso downward bringing elbows toward knees.
3. Squeeze abs hard at bottom, return with control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-machine-crunch',
      name: 'Machine Abdominal Crunch',
      muscleGroup: 'Core',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Sit in machine, adjust chest pad or handles.
2. Crunch ribcage down toward pelvis against resistance.
3. Hold contraction for 1 second, control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-ab-wheel-rollout',
      name: 'Ab Wheel Rollout',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Kneel on floor holding ab wheel under shoulders.
2. Roll wheel forward keeping core braced and hips tucked.
3. Roll out as far as possible without arching lower back, pull back in.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-decline-crunch',
      name: 'Decline Bench Crunch',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hook legs into decline bench and lie back.
2. Curl shoulders and upper back off bench toward knees.
3. Squeeze upper abs, lower under control.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-flat-bench-leg-raise',
      name: 'Flat Bench Leg Raise',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie flat on bench holding edges beside head.
2. Keep legs straight and raise them up to vertical.
3. Lower legs slowly until hovering just above bench level.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-russian-twist',
      name: 'Russian Twists (Weighted)',
      muscleGroup: 'Core',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Sit on floor with knees bent, torso reclined at 45°, feet off floor.
2. Hold weight plate or dumbbell with both hands.
3. Rotate torso smoothly from side to side tapping weight on floor.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-forearm-plank',
      name: 'Forearm Plank',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Rest on forearms with elbows under shoulders, body in straight line.
2. Squeeze glutes, tuck pelvis, pull belly button to spine.
3. Hold static tension without letting hips sag or pike.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-side-plank',
      name: 'Side Plank',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on side with elbow under shoulder, feet stacked.
2. Lift hips off floor until body forms straight diagonal line.
3. Hold position engaging obliques and lateral core.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-side-plank-dips',
      name: 'Side Plank Dips',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Assume side plank position on forearm.
2. Dip hips down toward floor, then drive them high into arched contraction.
3. Squeeze obliques intensely at top.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-cable-woodchopper',
      name: 'Cable Woodchopper (Diagonal)',
      muscleGroup: 'Core',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set cable high, stand sideways and grip handle with both hands.
2. Pull handle diagonally down across body toward opposite knee.
3. Rotate torso using obliques, control return.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-cable-woodchopper-low',
      name: 'Cable Woodchopper (Low to High)',
      muscleGroup: 'Core',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set cable at floor level, stand sideways.
2. Pull handle diagonally upward across body above opposite shoulder.
3. Pivot on rear foot driving through hips and obliques.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-pallof-press',
      name: 'Cable Pallof Press (Anti-Rotation)',
      muscleGroup: 'Core',
      equipment: 'Cable',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand sideways to cable at chest height holding handle at sternum.
2. Press handle straight out in front of chest resisting rotational pull.
3. Hold for 2 seconds, pull back to chest.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-hollow-body',
      name: 'Hollow Body Hold',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie flat on back with lower back pressed firmly into floor.
2. Extend arms overhead and elevate legs 6 inches off ground.
3. Hold banana shape maintaining complete lower back contact.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-mountain-climbers',
      name: 'Mountain Climbers',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Start in high plank position with hands under shoulders.
2. Drive one knee toward chest, then alternate quickly in running motion.
3. Keep hips level and core braced throughout.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-bicycle-crunch',
      name: 'Bicycle Crunch',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on back with hands behind head, legs in tabletop position.
2. Bring right elbow to left knee while extending right leg straight.
3. Alternate sides in smooth bicycling rhythm.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-dead-bug',
      name: 'Dead Bug',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lie on back with arms straight up and knees bent at 90° in air.
2. Press lower back into floor. Slowly lower opposite arm and leg toward floor.
3. Return to center and repeat on opposite side.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-bird-dog',
      name: 'Bird Dog',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Start on hands and knees with neutral spine.
2. Reach opposite arm and leg straight out without tilting pelvis.
3. Hold for 1 second, return and switch sides.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-v-ups',
      name: 'V-Ups',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie flat on back with arms extended overhead.
2. Simultaneously lift legs and torso into a "V" shape, touching toes at top.
3. Lower with control back to floor.''',
      isCustom: false,
    ),
    Exercise(
      id: 'core-dragon-flag',
      name: 'Dragon Flag (Bruce Lee)',
      muscleGroup: 'Core',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on flat bench holding bench edges behind head.
2. Lift entire body into air supported only by upper back and shoulders.
3. Lower rigid straight body slowly toward bench, then pull back up.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-treadmill-run',
      name: 'Treadmill Running',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Set speed and incline to desired level.
2. Run with natural upright posture, midfoot strike, and relaxed arms.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-incline-walk',
      name: 'Incline Treadmill Walk',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Set treadmill incline to 10-15% and speed to 3.0-3.5 mph.
2. Walk with long strides without holding handrails for maximum calorie burn.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-sprint-intervals',
      name: 'Sprint Intervals (HIIT)',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Warm up thoroughly.
2. Sprint at maximum speed for 20-30 seconds.
3. Rest or jog for 60 seconds. Repeat for 8-12 intervals.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-assault-bike',
      name: 'Assault AirBike',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Push and pull handles while pedaling forcefully.
2. Fan provides progressive wind resistance with speed.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-rowing-machine',
      name: 'Rowing Machine (Ergometer)',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Drive with legs first, lean back slightly, pull handle to lower ribs.
2. Return arms forward, hinge at hips, slide knees back to catch.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-stationary-bike',
      name: 'Stationary Bike (Spinning)',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Adjust seat height so knees have slight bend at bottom of pedal stroke.
2. Maintain consistent cadence (80-100 RPM).''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-stairmaster',
      name: 'StairMaster / StepMill',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Climb stairs at continuous pace with upright posture.
2. Avoid leaning heavily on handrails to maximize leg work.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-elliptical',
      name: 'Elliptical Cross Trainer',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Push and pull handles while moving pedals in smooth elliptical motion.
2. Great low-impact cardiovascular conditioning.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-skierg',
      name: 'SkiErg',
      muscleGroup: 'Cardio',
      equipment: 'Machine',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Stand facing SkiErg with arms overhead gripping handles.
2. Pull down powerfully engaging core, triceps, and lats into quarter squat.
3. Extend back up to overhead reach.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-jump-rope',
      name: 'Jump Rope (Speed / Boxer)',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Hold handles with elbows tucked, rotate rope using wrists.
2. Jump on balls of feet just 1-2 inches off floor.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-double-unders',
      name: 'Double Unders (Jump Rope)',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Jump slightly higher than standard rope skip.
2. Spin wrists twice per jump so rope passes under feet twice per bound.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-battle-ropes',
      name: 'Battle Ropes (Alternating Waves)',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Assume quarter squat stance holding rope ends.
2. Create rapid alternating waves by whipping arms up and down.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-battle-rope-slams',
      name: 'Battle Ropes (Double Slams)',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Raise both arms overhead simultaneously.
2. Slam ropes into floor aggressively with full core flexion.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-kb-swing',
      name: 'Kettlebell Swing (Russian)',
      muscleGroup: 'Cardio',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Hinge at hips with kettlebell between legs.
2. Snap hips forward powerfully propelling bell to chest level.
3. Let bell float, guide back into hip hinge.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-kb-swing-american',
      name: 'Kettlebell Swing (American)',
      muscleGroup: 'Cardio',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Snap hips forward driving kettlebell in a continuous arc overhead.
2. Lock out arms overhead with bell inverted over crown.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-kb-snatch',
      name: 'Kettlebell Snatch',
      muscleGroup: 'Cardio',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Swing kettlebell back through legs, drive hips forward.
2. Pull kettlebell vertically close to body and punch through overhead.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-kb-clean-press',
      name: 'Kettlebell Clean and Press',
      muscleGroup: 'Cardio',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Clean kettlebell into racked position on chest.
2. Press bell straight overhead to lockout, then lower.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-turkish-getup',
      name: 'Turkish Get-Up',
      muscleGroup: 'Cardio',
      equipment: 'Kettlebell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Lie on back holding bell pressed overhead.
2. Roll to elbow, then hand, bridge hips, sweep leg back into lunge.
3. Stand tall with bell overhead, then reverse sequence.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-burpees',
      name: 'Burpees',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Drop into squat, kick feet back into plank.
2. Lower chest to floor in push-up, press up, jump feet forward.
3. Explode vertically with hands overhead.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-box-jumps',
      name: 'Box Jumps',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand facing 20-30" plyo box.
2. Swing arms back, explode upward landing softly on box in quarter squat.
3. Stand tall, step down carefully.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-sled-push',
      name: 'Prowler / Sled Push',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Grip upright poles of heavy sled with arms extended.
2. Drive through toes with powerful forward sprinting strides.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-sled-drag',
      name: 'Sled Drag / Pull',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Attach harness or strap to sled and walk backward or forward.
2. Builds massive quad endurance and knee resilience.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-farmers-walk',
      name: 'Dumbbell Farmer\'s Walk',
      muscleGroup: 'Cardio',
      equipment: 'Dumbbell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Pick up heavy dumbbells with good posture.
2. Walk continuously for distance or time with braced core.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-trap-bar-carry',
      name: 'Trap Bar Carry',
      muscleGroup: 'Cardio',
      equipment: 'Barbell',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions: '''1. Stand inside heavy trap bar and deadlift to standing.
2. Walk forward with measured strides for maximum conditioning.''',
      isCustom: false,
    ),
    Exercise(
      id: 'cardio-sandbag-carry',
      name: 'Sandbag Clean & Carry',
      muscleGroup: 'Cardio',
      equipment: 'None',
      imageUrl:
          'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&auto=format&fit=crop&q=80',
      instructions:
          '''1. Lap heavy sandbag from floor, pop hips and bear-hug bag to chest.
2. Walk forward briskly under deep core and lung demand.''',
      isCustom: false,
    ),
  ];
}
