import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Lesson } from './lesson.entity';

@Entity('course_levels')
export class CourseLevel {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string; // e.g. "HSK 1", "HSK 2", "TOCFL A1"

  @Column({ nullable: true })
  description: string;

  @Column({ default: 0 })
  totalLessons: number;

  @OneToMany(() => Lesson, (lesson) => lesson.courseLevel)
  lessons: Lesson[];
}
